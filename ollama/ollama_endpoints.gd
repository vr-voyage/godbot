class_name OllamaEndpoints extends Node

class ResponseField:
	var field_type:int
	var field_description:String
	func _init(provided_description:String, provided_type:int):
		field_type = provided_type
		field_description = provided_description

class OllamaEndpoint:
	var path:String
	var method:HTTPClient.Method
	var parameters:Dictionary[String,int]
	var required_parameters:PackedStringArray
	var response:Dictionary[String,ResponseField]

	func _init(endpoint_path:String, endpoint_method:HTTPClient.Method, endpoint_parameters:Dictionary[String,int], endpoint_required_parameters:PackedStringArray, expected_response:Dictionary[String,ResponseField]):
		path = endpoint_path
		method = endpoint_method
		parameters = endpoint_parameters
		required_parameters = endpoint_required_parameters
		response = expected_response

static var endpoints:Dictionary[String,OllamaEndpoint] = {
	"generate_a_completion": OllamaEndpoint.new(
		"/api/generate",
		HTTPClient.METHOD_POST,
		{
			"model": TYPE_STRING,
			"prompt": TYPE_STRING,
			"suffix": TYPE_STRING,
			"images": TYPE_ARRAY,
			"format": TYPE_STRING,
			"options": TYPE_STRING,
			"system": TYPE_STRING,
			"template": TYPE_STRING,
			"stream": TYPE_STRING,
			"raw": TYPE_STRING,
			"keep_alive": TYPE_STRING,
			"context": TYPE_STRING
		},
		["model"],
		{
			"model": ResponseField.new("the model name", TYPE_STRING),
			"created_at": ResponseField.new("The moment the answer was generated", TYPE_STRING),
			"total_duration": ResponseField.new("time spent generating the response", TYPE_INT),
			"load_duration": ResponseField.new("time spent in nanoseconds loading the model", TYPE_INT),
			"prompt_eval_count": ResponseField.new("number of tokens in the prompt", TYPE_INT),
			"prompt_eval_duration": ResponseField.new("time spent in nanoseconds evaluating the prompt", TYPE_INT),
			"eval_count": ResponseField.new("number of tokens in the response", TYPE_INT),
			"eval_duration": ResponseField.new("time in nanoseconds spent generating the response", TYPE_INT),
			"context": ResponseField.new("an encoding of the conversation used in this response, this can be sent in the next request to keep a conversational memory", TYPE_STRING),
			"response": ResponseField.new("empty if the response was streamed, if not streamed, this will contain the full response", TYPE_STRING),
			"done": ResponseField.new("Indicate whether the task is done or not", TYPE_BOOL)
		}),
	"generate_a_chat_completion": OllamaEndpoint.new(
		"/api/chat",
		HTTPClient.METHOD_POST,
		{
			"model": TYPE_STRING,
			"messages": TYPE_ARRAY,
			"tools": TYPE_ARRAY,
			"format": TYPE_STRING,
			"options": TYPE_STRING,
			"stream": TYPE_STRING,
			"keep_alive": TYPE_STRING
		},
		["model"],
		{
			"model": ResponseField.new("the model name", TYPE_STRING),
			"created_at": ResponseField.new("The moment the answer was generated", TYPE_STRING),
			"message": ResponseField.new("The provided answer", TYPE_DICTIONARY),
			"done": ResponseField.new("Indicate whether the task is done or not", TYPE_BOOL),
			"total_duration": ResponseField.new("time spent generating the response", TYPE_INT),
			"load_duration": ResponseField.new("time spent in nanoseconds loading the model", TYPE_INT),
			"prompt_eval_count": ResponseField.new("number of tokens in the prompt", TYPE_INT),
			"prompt_eval_duration": ResponseField.new("time spent in nanoseconds evaluating the prompt", TYPE_INT),
			"eval_count": ResponseField.new("number of tokens in the response", TYPE_INT),
			"eval_duration": ResponseField.new("time in nanoseconds spent generating the response", TYPE_INT),
			"context": ResponseField.new("an encoding of the conversation used in this response, this can be sent in the next request to keep a conversational memory", TYPE_STRING)
		}),
	"create_a_model": OllamaEndpoint.new(
		"/api/create",
		HTTPClient.METHOD_POST,
		{
			"model": TYPE_STRING,
			"from": TYPE_STRING,
			"files": TYPE_STRING,
			"adapters": TYPE_STRING,
			"template": TYPE_STRING,
			"license": TYPE_STRING,
			"system": TYPE_STRING,
			"parameters": TYPE_STRING,
			"messages": TYPE_ARRAY,
			"stream": TYPE_STRING,
			"quantize": TYPE_STRING
		},
		["model"],
		{
			"status": ResponseField.new("The creation status", TYPE_STRING)
		}),
	"list_local_models": OllamaEndpoint.new(
		"/api/tags",
		HTTPClient.METHOD_GET,
		{},
		[],
		{
			"name": ResponseField.new("The model name", TYPE_STRING),
			"modified_at": ResponseField.new("The last modified date", TYPE_STRING),
			"size": ResponseField.new("The model size in bytes", TYPE_STRING),
			"digest": ResponseField.new("The model digest", TYPE_STRING),
			"details": ResponseField.new("Details about the model", TYPE_STRING)
		}),
	"show_model_information": OllamaEndpoint.new(
		"/api/show",
		HTTPClient.METHOD_POST,
		{
			"model": TYPE_STRING,
			"verbose": TYPE_STRING
		},
		["model"],
		{
			"modelfile": ResponseField.new("The content of the ModelFile associated with this model", TYPE_STRING),
			"parameters": ResponseField.new("The list of parameters associated with this model", TYPE_ARRAY),
			"template": ResponseField.new("The default template", TYPE_STRING),
			"details": ResponseField.new("The model details", TYPE_STRING),
			"model_info": ResponseField.new("Advanced information about this model", TYPE_STRING),
			"capabilities": ResponseField.new("The capabilities of this model", TYPE_STRING)
		}),
	"copy_a_model": OllamaEndpoint.new(
		"/api/copy",
		HTTPClient.METHOD_POST,
		{
			"source": TYPE_STRING,
			"destination": TYPE_STRING
		},
		["source", "destination"],
		{}),
	"delete_a_model": OllamaEndpoint.new(
		"/api/delete",
		HTTPClient.METHOD_DELETE,
		{
			"model": TYPE_STRING
		},
		["model"],
		{}),
	"pull_a_model": OllamaEndpoint.new(
		"/api/pull",
		HTTPClient.METHOD_POST,
		{
			"model": TYPE_STRING,
			"insecure": TYPE_STRING,
			"stream": TYPE_STRING
		},
		["model"],
		{
			"status": ResponseField.new("The current status of the operation", TYPE_STRING),
			"digest": ResponseField.new("The downloaded model name", TYPE_STRING),
			"total": ResponseField.new("The total amount of data to download in bytes", TYPE_STRING),
			"completed": ResponseField.new("The downloaded amount of data in bytes", TYPE_STRING)
		}),
	"push_a_model": OllamaEndpoint.new(
		"/api/push",
		HTTPClient.METHOD_POST,
		{
			"model": TYPE_STRING,
			"insecure": TYPE_STRING,
			"stream": TYPE_STRING
		},
		["model"],
		{
			"status": ResponseField.new("The current status of the push operation", TYPE_STRING),
			"digest": ResponseField.new("The uploaded model sha256", TYPE_STRING),
			"total": ResponseField.new("The total amount of data uploaded in bytes", TYPE_STRING)
		}),
	"generate_embeddings": OllamaEndpoint.new(
		"/api/embed",
		HTTPClient.METHOD_POST,
		{
			"model": TYPE_STRING,
			"input": TYPE_STRING,
			"truncate": TYPE_STRING,
			"options": TYPE_STRING,
			"keep_alive": TYPE_STRING
		},
		["model", "input"],
		{
			"model": ResponseField.new("name of model from which the embeddings are generated", TYPE_STRING),
			"embeddings": ResponseField.new("The generated embeddings", TYPE_ARRAY),
			"total_duration": ResponseField.new("The duration of the operation", TYPE_INT),
			"load_duration": ResponseField.new("The duration of the loading", TYPE_INT),
			"prompt_eval_count": ResponseField.new("The number of tokens in the prompt", TYPE_INT)
		}),
	"list_running_models": OllamaEndpoint.new(
		"/api/ps",
		HTTPClient.METHOD_GET,
		{},
		[],
		{
			"name": ResponseField.new("The loaded model name", TYPE_STRING),
			"model": ResponseField.new("The loaded model complete name", TYPE_STRING),
			"size": ResponseField.new("The size of the loaded model", TYPE_STRING),
			"digest": ResponseField.new("The digest of the loaded model", TYPE_STRING),
			"details": ResponseField.new("The details of the loaded model", TYPE_STRING),
			"expires_at": ResponseField.new("When the model will be unloaded", TYPE_STRING),
			"size_vram": ResponseField.new("The size of the loaded model in VRAM", TYPE_STRING)
		})
}
