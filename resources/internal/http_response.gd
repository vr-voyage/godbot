class_name HTTPResponse extends Resource

var success:bool = false
var body:PackedByteArray = []
var godot_code:HTTPRequest.Result = HTTPRequest.RESULT_NO_RESPONSE
var http_code:HTTPClient.ResponseCode = HTTPClient.RESPONSE_NOT_IMPLEMENTED
var headers:PackedStringArray = []

func connection_failed() -> bool:
	return godot_code != HTTPRequest.RESULT_SUCCESS

func http_error() -> bool:
	return http_code >= 400
