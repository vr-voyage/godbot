class_name VllmConnection extends Node

var configuration:VllmConnectionConfiguration
@export var http_queue:HttpRequestsQueue

func get_http_headers() -> Dictionary[String,String]:
	return {"Content-Type": "application/json"}

func set_configuration(new_configuration:VllmConnectionConfiguration):
	configuration = new_configuration
	if not is_configured():
		return
	http_queue.prefix = "http://%s:%s/v1" % [configuration.ip, configuration.port]

func is_configured() -> bool:
	return configuration != null

func request_models_list(callback:Callable):
	if not is_configured():
		printerr("[VllmConnection:BUG] Trying to request models list while not configured")
		return
	http_queue.plan_request(callback, HTTPClient.Method.METHOD_GET, "/models", "", get_http_headers())

func chat_request(callback:Callable, model:String, prompts:Array[AiChatPrompt]):
	if not is_configured():
		printerr("[VllmConnection:BUG] Trying to request a Chat while not configured")
		return

	var request:Dictionary = {
		"model": model,
		"messages": []
	}
	for prompt in prompts:
		request["messages"].append({"role": prompt.role, "content": prompt.content})

	http_queue.plan_request(
		callback,
		HTTPClient.Method.METHOD_POST,
		"/chat/completions",
		JSON.stringify(request),
		get_http_headers())
