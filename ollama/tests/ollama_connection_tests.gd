extends Control

@export var ollama_connection:OllamaConnection

func _ollama_response(status, content):
	print_debug(status)
	print_debug(content)

func _ready():
	ollama_connection.chat_request_response.connect(_ollama_response)
	ollama_connection.pull_model_response.connect(_ollama_response)

#	var pull_request := OllamaModelPullRequest.new()
#	pull_request.model = "gemma3:1b"
#	ollama_connection.send_pull_model_request(pull_request)

	var chat_request := OllamaChatCompletionRequest.new()
	chat_request.model = "gemma3:1b"
	chat_request.stream = false
	chat_request.add_prompt("In Unity, how to spawn a GameObject in C# ?")
	
	ollama_connection.send_chat_request(chat_request)
	
