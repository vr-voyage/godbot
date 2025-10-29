class_name OllamaConnection extends Node

class HttpRequestInfo:
	var method:HTTPClient.Method
	var url:String
	var additional_headers:Dictionary[String,String]
	var data:String
	var callback_signal:Signal

	func _init(conf:OllamaConnectionConfiguration, endpoint:OllamaEndpoints.OllamaEndpoint):
		url = "http://%s:%s%s" % [conf.ip, conf.port, endpoint.path]
		method = endpoint.method
		additional_headers["Content-Type"] = "application/json"

	func headers_as_packed_string_array() -> PackedStringArray:
		var headers_array := PackedStringArray()
		for header_key in additional_headers:
			var header_value := additional_headers[header_key]
			headers_array.append("%s: %s" % [header_key, header_value])
		return headers_array

signal chat_request_response(status, content)
signal pull_model_response(status, content)
signal list_models_response(status, content)

var configuration:OllamaConnectionConfiguration

#@export var ollama_server_port := 11434
#@export var ollama_server_address := "127.0.0.1"

var current_request:HTTPRequest = null
var queued_requests:Array[HttpRequestInfo]

func _init():
	configuration = OllamaConfigurationParser.parse_configuration_from_environment()

func _enter_tree():
	if configuration == null:
		get_tree().quit(2)

func send_request(
	ollama_request:OllamaRequest,
	endpoint_name:String,
	callback_signal:Signal) -> void:
	if configuration == null:
		return

	print_debug("[OllamaConnection] Sending request %s !" % ClassHelpers.get_class_of(ollama_request))
	var http_request := HttpRequestInfo.new(
		configuration,
		OllamaEndpoints.endpoints[endpoint_name])
	var data_as_dict := ollama_request.to_dictionary()
	http_request.data = JSON.stringify(data_as_dict)
	http_request.callback_signal = callback_signal
	queued_requests.append(http_request)
	set_process(true)

func send_chat_request(
	completion_request:OllamaChatCompletionRequest):
	send_request(
		completion_request,
		"generate_a_chat_completion",
		chat_request_response)
	return

func send_pull_model_request(
	pull_model_request:OllamaModelPullRequest):
	send_request(
		pull_model_request,
		"pull_a_model",
		pull_model_response)
	return

func send_list_models_request(request:OllamaListModelsRequest):
	send_request(request, "list_local_models", list_models_response)

func _http_request_completed2(
	result: int,
	_response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
	callback_signal:Signal):
	print_debug("[OllamaConnection] Received HTTP Request result")
	if result != HTTPRequest.RESULT_SUCCESS:
		callback_signal.emit(ERR_QUERY_FAILED, "The request failed with result %d")
		return

	print_debug("[OllamaConnection] Request succeeded... ?")
	var content_as_string:String = body.get_string_from_utf8()
	if content_as_string == null:
		printerr("[BUG] Ollama gave us a non-string response ... ???")
		callback_signal.emit(ERR_INVALID_DATA, "Ollama didn't return String data")
		return

	var chat_response = JSON.parse_string(content_as_string)
	if chat_response == null:
		printerr("[BUG] Ollama response was not JSON content ! (Content %s)" % content_as_string)
		callback_signal.emit(ERR_INVALID_DATA, "Ollama didn't return a JSON")
		return

	print_debug("[OllamaConnection] Emit Chat request response !")
	callback_signal.emit(OK, chat_response)

	current_request.queue_free()
	current_request = null

func _process(_delta):
	if current_request != null:
		return

	if queued_requests.is_empty():
		set_process(false)
		return

	var queued_request:HttpRequestInfo = queued_requests.pop_front()
	var new_http_request := HTTPRequest.new()

	var http_response_handler:Callable = _http_request_completed2.bind(
		queued_request.callback_signal)
	new_http_request.request_completed.connect(http_response_handler)

	add_child(new_http_request)
	current_request = new_http_request

	print_debug("%s %s -> %s" % [queued_request.method, queued_request.url, queued_request.data])

	new_http_request.request(
		queued_request.url,
		queued_request.headers_as_packed_string_array(),
		queued_request.method,
		queued_request.data)
