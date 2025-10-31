extends Control

@export var vllm_connection:VllmConnection
@export var vllm_connection_configuration:VllmConnectionConfiguration

func _vllm_response(result:HTTPResponse):
	print_debug(result.godot_code)
	print_debug(result.http_code)
	if not result.connection_failed() or not result.http_error():
		print(result.body.get_string_from_utf8())

func _ready():
	vllm_connection.set_configuration(vllm_connection_configuration)
	vllm_connection.request_models_list(_vllm_response)
	vllm_connection.chat_request(
		_vllm_response,
		"Qwen/Qwen2.5-1.5B-Instruct",
		[AiChatPrompt.new("In Unity, how to spawn a GameObject in C# ?")])
