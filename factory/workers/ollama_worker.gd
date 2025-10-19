class_name OllamaWorker extends FactoryWorker

@export var consumes:PackedStringArray = ["AiChatRequest"]
@export var produces:PackedStringArray = ["AiChatResponse", "AiChatResponseChunk"]

@export var current_job:AiChatRequest

@export var ollama_connection:OllamaConnection

func emit_job_finished(success:bool, reason:String = ""):
	var job_finished := FactoryJobDone.new()
	job_finished.id = current_job.id
	job_finished.success = success
	job_finished.reason = reason
	current_job = null
	job_done.emit(job_finished)

func already_got_a_job() -> bool:
	return current_job != null

func convert_to_chat_job_response(response:Dictionary):
	if response == null:
		job_failed("Invalid data provided")
		return

	if response.has("error"):
		job_failed("Ollama error : %s" % response["error"])
		return

	if not response.has_all(["model", "message", "done"]):
		job_failed("Unexpected response from Ollama : %s" % JSON.stringify(response))
		return

	var chat_response := AiChatResponse.new()
	chat_response.id = current_job.id
	chat_response.response = response["message"]["content"]
	var chat_finished:bool = response.get("done", true)
	chat_response.complete = chat_finished
	job_done.emit(chat_response)

	if chat_finished:
		emit_job_finished(true)

func job_failed(reason:String):
	emit_job_finished(false, reason)
	print_debug("Current Job is NULL")

func _ollama_response_chat(status:int, response_content):
	if status != OK:
		job_failed(response_content)
	convert_to_chat_job_response(response_content as Dictionary)

func _ollama_response_list_models(_response:Dictionary):
	# TODO
	pass

func _ollama_response_get_model(_response:Dictionary):
	# TODO
	pass

func _ollama_response_current_state(_response:Dictionary):
	# TODO
	pass

func send_chat_request(chat_request:OllamaChatCompletionRequest):
	ollama_connection.send_chat_request(chat_request)

func set_connections():
	if ollama_connection == null:
		return

	ollama_connection.chat_request_response.connect(_ollama_response_chat)
	#ollama_connection.list_models.connect(_ollama_response_list_models)
	#ollama_connection.get_model.connect(_ollama_response_get_model)
	#ollama_connection.current_state.connect(_ollama_response_current_state)

func set_ollama_connection(new_connection):
	if ollama_connection != null:
		remove_connections()

	ollama_connection = new_connection
	set_connections()

func remove_connections():
	if ollama_connection == null:
		return

	ollama_connection.chat_request_resopnse.disconnect(_ollama_response_chat)
	#ollama_connection.list_models.disconnect(_ollama_response_list_models)
	#ollama_connection.get_model.disconnect(_ollama_response_get_model)
	#ollama_connection.current_state.disconnect(_ollama_response_current_state)

func _ready():
	super._ready()
	set_connections()

func can_accept_job(job) -> bool:
	if already_got_a_job():
		print_debug("Worker already have a job")
		return false

	var chat_job:AiChatRequest = job as AiChatRequest
	if chat_job == null:
		print_debug("Not an Ai Chat Request. Ignoring")
		return false
	return true

func receive_job(job) -> bool:
	if !can_accept_job(job):
		return false

	var chat_job:AiChatRequest = job as AiChatRequest

	current_job = job
	print_debug("Current Job is %s" % str(current_job.id))

	var chat_request := OllamaChatCompletionRequest.new()

	chat_request.model = chat_job.model
	if chat_job.system_prompt:
		chat_request.add_prompt(chat_job.system_prompt, "system")

	chat_request.add_prompt(chat_job.user_prompt)
	send_chat_request(chat_request)

	return true

func handled_jobs_types() -> PackedStringArray:
	return consumes
