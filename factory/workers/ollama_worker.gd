class_name OllamaWorker extends FactoryWorker

# signal job_done is defined by the parent

@export var consumes:PackedStringArray = ["AiChatRequest", "AiListModelsRequest"]
@export var produces:PackedStringArray = ["AiChatResponse", "AiChatResponseChunk", "AiListModelsResponse"]
@export var current_job:FactoryJob
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

func convert_to_list_models_response(response:Dictionary):
	if response == null:
		job_failed("Invalid data provided")
		return

	if response.has("error"):
		job_failed("Ollama error : %s" % response["error"])
		return

	var models_raw = response.get("models", [])
	if models_raw == null or not models_raw is Array:
		job_failed("Unexpected response from Ollama" % JSON.stringify(response))
		return

	print_debug("[OllamaWorker] Received Models List. Proceeding to conversion")

	var models:Array = models_raw as Array
	var models_list_response := AiListModelsResponse.new()
	models_list_response.models = []
	for model_informations_raw in models:
		if not model_informations_raw is Dictionary:
			continue
		var model_informations:Dictionary = model_informations_raw as Dictionary
		if not model_informations.has_all(["name", "model"]):
			printerr("[BUG] Provided model information format changed")
			continue
		var provided_response := AiModelDescription.new()
		provided_response.internal_name = model_informations["name"]
		provided_response.presentation_name = model_informations["name"]
		provided_response.description = model_informations["name"]
		models_list_response.models.append(provided_response)
	print_debug("[OllamaWorker] Job done !")
	job_done.emit(models_list_response)
	# TODO This should be there... We need to review the design
	current_job = null

func _ollama_response_list_models(status:int, response_content):
	if status != OK:
		job_failed(response_content as String)
	convert_to_list_models_response(response_content as Dictionary)

func _ollama_response_get_model(_response:Dictionary):
	# TODO
	pass

func _ollama_response_current_state(_response:Dictionary):
	# TODO
	pass

func send_list_models_request(chat_request:OllamaListModelsRequest):
	ollama_connection.send_list_models_request(chat_request)

func send_chat_request(chat_request:OllamaChatCompletionRequest):
	ollama_connection.send_chat_request(chat_request)

func set_connections():
	if ollama_connection == null:
		return

	ollama_connection.chat_request_response.connect(_ollama_response_chat)
	ollama_connection.list_models_response.connect(_ollama_response_list_models)
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
	ollama_connection.list_models_response.disconnect(_ollama_response_list_models)
	#ollama_connection.get_model.disconnect(_ollama_response_get_model)
	#ollama_connection.current_state.disconnect(_ollama_response_current_state)

func _ready():
	super._ready()
	set_connections()

func can_accept_job(job) -> bool:
	if already_got_a_job():
		print_debug("Worker already have a job")
		return false

	var job_type:String = ClassHelpers.get_class_of(job)
	if consumes.find(job_type) == -1:
		print_debug("Can't handle that kind of job (%s)" % job_type)
		return false
	return true

func deal_with_ai_chat_request(chat_job:AiChatRequest):
	print_debug("Current Job is %s" % str(current_job.id))

	var chat_request := OllamaChatCompletionRequest.new()
	chat_request.model = chat_job.model
	for prompt in chat_job.prompts:
		chat_request.add_prompt(prompt)

	send_chat_request(chat_request)

func deal_with_list_models_request(_list_models_job:AiListModelsRequest):
	print_debug("[OllamaWorker] Requesting models list")
	var list_models_request := OllamaListModelsRequest.new()
	send_list_models_request(list_models_request)

func receive_job(job) -> bool:
	if !can_accept_job(job):
		return false

	current_job = job
	var job_type:String = ClassHelpers.get_class_of(job)
	match job_type:
		"AiChatRequest":
			deal_with_ai_chat_request(job)
			return true
		"AiListModelsRequest":
			deal_with_list_models_request(job)
			return true

	return false

func handled_jobs_types() -> PackedStringArray:
	return consumes
