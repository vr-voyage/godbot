class_name OllamaConnection extends Node

class HttpRequestInfo:
	var method:HTTPClient.Method
	var url:String
	var additional_headers:Dictionary[String,String]
	var data:String
	var success_callback:Callable
	var error_callback:Callable

	func _init(connection:OllamaConnection, endpoint:OllamaEndpoints.OllamaEndpoint):
		url = "http://%s:%s%s" % [
			connection.ollama_server_address,
			connection.ollama_server_port,
			endpoint.path]
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

@export var ollama_server_port := 11434
@export var ollama_server_address := "127.0.0.1"

var current_request:HTTPRequest = null
var queued_requests:Array[HttpRequestInfo]

# TODO Factorize !
func send_chat_request(
	completion_request:OllamaChatCompletionRequest):
	print_debug("[OllamaConnection] Sending chat request !")
	var request := HttpRequestInfo.new(
		self,
		OllamaEndpoints.endpoints["generate_a_chat_completion"])
	var data_as_dict := completion_request.to_dictionary()
	request.data = JSON.stringify(data_as_dict)
	request.success_callback = chat_request_succeeded
	request.error_callback = chat_request_failed
	queued_requests.append(request)
	set_process(true)

func send_pull_model_request(
	pull_model_request:OllamaModelPullRequest):
	var request := HttpRequestInfo.new(
		self,
		OllamaEndpoints.endpoints["pull_a_model"])
	var data_as_dict := pull_model_request.to_dictionary()
	request.data = JSON.stringify(data_as_dict)
	request.success_callback = pull_model_succeeded
	request.error_callback = pull_model_failed
	queued_requests.append(request)
	set_process(true)

func _http_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
	success_callback:Callable,
	error_callback:Callable):
	print_debug("[OllamaConnection] Received HTTP Request result")
	if result != HTTPRequest.RESULT_SUCCESS:
		error_callback.call(result, response_code)
		return

	success_callback.call(body)
	current_request.queue_free()
	current_request = null

func chat_request_succeeded(content:PackedByteArray):
	print_debug("[OllamaConnection] Chat request succeeded !")
	var content_as_string:String = content.get_string_from_utf8()
	if content_as_string == null:
		printerr("[BUG] Ollama gave us a non-string response ... ???")
		chat_request_response.emit(ERR_INVALID_DATA, "Ollama didn't return String data")
		return

	var chat_response = JSON.parse_string(content_as_string)
	if chat_response == null:
		printerr("[BUG] Ollama response was not JSON content ! (Content %s)" % content_as_string)
		chat_request_response.emit(ERR_INVALID_DATA, "Ollama didn't return a JSON")
		return

	print_debug("[OllamaConnection] Emit Chat request response !")
	chat_request_response.emit(OK, chat_response)

func chat_request_failed(result:int, response_code:int):
	chat_request_response.emit(ERR_QUERY_FAILED, "The query failed with the following errors : %d,%d" % [response_code,result])

func pull_model_succeeded(content:PackedByteArray):
	var content_as_string:String = content.get_string_from_utf8()
	if content_as_string == null:
		printerr("[BUG] Ollama gave us a non-string response ... ???")
		pull_model_response.emit(ERR_INVALID_DATA, "Ollama didn't return String data")
		return

	var chat_response = JSON.parse_string(content_as_string)
	if chat_response == null:
		printerr("[BUG] Ollama response was not JSON content !")
		pull_model_response.emit(ERR_INVALID_DATA, "Ollama didn't return a JSON")
		return

	pull_model_response.emit(OK, chat_response)

func pull_model_failed(result:int, response_code:int):
	pull_model_response.emit(ERR_QUERY_FAILED, "The query failed with the following errors : %d,%d" % [response_code,result])


func _process(_delta):
	if current_request != null:
		return

	if queued_requests.is_empty():
		set_process(false)
		return

	var queued_request:HttpRequestInfo = queued_requests.pop_front()
	var new_http_request := HTTPRequest.new()

	var http_response_handler:Callable = _http_request_completed.bind(
		queued_request.success_callback,
		queued_request.error_callback)
	new_http_request.request_completed.connect(http_response_handler)

	add_child(new_http_request)
	current_request = new_http_request

	print_debug("%s %s -> %s" % [queued_request.method, queued_request.url, queued_request.data])

	new_http_request.request(
		queued_request.url,
		queued_request.headers_as_packed_string_array(),
		queued_request.method,
		queued_request.data)
