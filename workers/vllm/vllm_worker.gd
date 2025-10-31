class_name VllmWorker extends FactoryWorker

@export var vllm_connection:VllmConnection

var current_job:FactoryJob

func _enter_tree():
	vllm_connection.set_configuration(VllmConfigurationParser.parse_configuration_from_environment())

func is_configured() -> bool:
	return vllm_connection.is_configured()

func already_got_a_job() -> bool:
	return current_job != null

func receive_job(job:FactoryJob) -> bool:
	if not is_configured() or already_got_a_job():
		return false

	current_job = job
	var job_type:String = ClassHelpers.get_class_of(job)
	match job_type:
		"AiChatRequest":
			chat_request(job)
		"AiListModelsRequest":
			list_models()
		_:
			printerr("[VllmWorker:ReceiveJob] Unhandled job type %s" % job_type)
			current_job = null
			return false
	return true

func handled_jobs_types() -> PackedStringArray:
	return ["AiChatRequest", "AiListModelsRequest"]

func list_models():
	vllm_connection.request_models_list(_cb_list_models)

func chat_request(job:AiChatRequest):
	vllm_connection.chat_request(_cb_chat_request, job.model, job.prompts)

# TODO : Can be factorized
func job_completed(succeeded:bool, reason:String = ""):
	var job_result := FactoryJobDone.new()
	job_result.id = current_job.id
	job_result.success = succeeded
	job_result.reason = reason
	current_job = null
	job_done.emit(job_result)

func job_failed(reason:String):
	job_completed(false, reason)

func _convert_models_list_response(response:String) -> AiListModelsResponse:
	var open_api_models_list := OpenAiModelsList.from_v1_json(response)
	if open_api_models_list == null:
		printerr("[VllmWorker:ListModels] %s is not a supported models list" % response)
		return

	var models_list_response := AiListModelsResponse.new()
	models_list_response.id = current_job.id
	var models_list:Array[AiModelDescription] = models_list_response.models
	for model in open_api_models_list.models:
		var model_description := AiModelDescription.new()
		model_description.internal_name = model
		model_description.description = model
		model_description.presentation_name = model
		models_list.append(model_description)
	return models_list_response

func _convert_chat_completion_response(response:String) -> AiChatResponse:
	var open_api_chat_response := OpenAiChatResponse.from_v1_json(response)
	if open_api_chat_response == null:
		printerr("[VllmWorker:ChatCompletionResponse] Could not parse response")
		return null

	# TODO We only manage 1 answer at the moment
	var chat_response := AiChatResponse.new()
	chat_response.id = current_job.id
	chat_response.complete = true
	# TODO Actually check the role here...
	chat_response.response = open_api_chat_response.choices[0].content

	return chat_response

func _cb_list_models(http_response:HTTPResponse):
	var body:String = http_response.body.get_string_from_utf8()
	if http_response.connection_failed() or http_response.http_error():
		printerr("[VllmWorker:ListModels] Could not retrieve models list : (%d, %d, %s)" % [
			http_response.godot_code, http_response.http_code, body])
		return

	var models_list := _convert_models_list_response(body)
	if models_list == null:
		return

	job_done.emit(models_list)
	current_job = null

func _cb_chat_request(http_response:HTTPResponse):
	var body:String = http_response.body.get_string_from_utf8()
	if http_response.connection_failed() or http_response.http_error():
		printerr("[VllmWorker:ChatRequest] Chat request result in an error : (%d, %d, %s)" % [
			http_response.godot_code, http_response.http_code, body])
		job_failed("Protocol error when requesting a chat")
		return

	var chat_completion := _convert_chat_completion_response(body)
	if chat_completion == null:
		job_failed("The provided result was not an expected Chat Completion Response")
		return

	job_done.emit(chat_completion)
	if chat_completion.complete:
		job_completed(true)
