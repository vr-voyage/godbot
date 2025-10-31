class_name HttpRequestsQueue extends Node

@export var prefix:String = ""

class PlannedRequest:
	var method:HTTPClient.Method
	var url:String
	var headers:Dictionary[String,String] = {}
	var data:String
	var callback:Callable

	func _init(new_method:HTTPClient.Method, new_url:String, new_headers:Dictionary[String,String] = {}, new_data:String = ""):
		method = new_method
		url = new_url
		headers = new_headers
		data = new_data

	func _headers_to_string_array(headers_dict:Dictionary[String,String]) -> PackedStringArray:
		var headers_array:PackedStringArray = []
		for header_name in headers_dict:
			var header_value := headers_dict[header_name]
			headers_array.append("%s: %s" % [header_name, header_value])
		return headers_array

	func headers_as_array() -> PackedStringArray:
		return _headers_to_string_array(headers)

	func _default_cb(response:HTTPResponse):
		print_debug(
			"[PlannedRequest] DEFAULT CB ! Success : %d, Body length : %d, Godot code : %d, Response code : %d" % [
				response.success, len(response.body),
				response.godot_code, response.http_code
			])

var planned_requests:Array[PlannedRequest] = []
var current_request:PlannedRequest = null
var current_http_request:HTTPRequest = null
var delay_between_request_seconds:float = 1.
var next_request_in:float = 1.

func _cb_http_request_completed(
	response_code:int,
	http_response_code:int,
	headers:PackedStringArray,
	body:PackedByteArray):
	if current_request == null:
		printerr("[BUG] Got an HTTP Response but we're not processing any request ???")
		return

	var response = HTTPResponse.new()
	response.success = (response_code == HTTPRequest.RESULT_SUCCESS and http_response_code < 400)
	response.body = body
	response.godot_code = response_code
	response.http_code = http_response_code
	response.headers = headers

	current_request.callback.call(response)
	current_request = null

	if current_http_request == null:
		printerr("[BUG] The HTTPRequest node already disappeared !!?")
		return
	current_http_request.queue_free()

func _send_planned_request(planned_request:PlannedRequest):
	var http_request:HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	current_http_request = http_request

	http_request.request_completed.connect(_cb_http_request_completed)
	http_request.request(
		planned_request.url,
		planned_request.headers_as_array(),
		planned_request.method,
		planned_request.data)

func _process(delta):
	next_request_in -= delta
	if next_request_in > 0:
		return

	if current_http_request == null:
		send_next_request()

func _ready():
	send_next_request()

func plan_request(
	callback:Callable,
	method:HTTPClient.Method,
	url:String,
	content:String = "",
	headers:Dictionary[String,String] = {}):
	var planned_request = PlannedRequest.new(
		method,
		prefix + url,
		headers,
		content)
	planned_request.callback = callback
	
	planned_requests.push_back(planned_request)
	set_process(true)

func send_next_request():
	if planned_requests.is_empty():
		set_process(false)
		return

	current_request = planned_requests.pop_front()
	_send_planned_request(current_request)
	next_request_in = delay_between_request_seconds
