class_name DiscordCustomerAgent extends Node

signal models_list_received(models_list)

@export var discord_bot:DiscordBot
@export var factory:AiJobFactory

enum DiscordRequestPath
{
	Invalid,
	DiscordChannel,
	DiscordThread,
	DiscordDM
}

enum RequestState
{
	Invalid,
	WaitingForAnswer,
	Answered
}

# TODO
# This class needs to be split
# The sub-job handlers (chat request, image request, ...)
# should call this agent to pass the jobs
class PromptHistory:
	var model_name:String = ""
	var prompts:Array[AiChatPrompt] = []

	func _init(first_model_name:String, first_prompts:Array[AiChatPrompt] = []):
		model_name = first_model_name
		prompts.append_array(first_prompts)

	func append(chat_prompt:AiChatPrompt):
		prompts.append(chat_prompt)

	func append_all(chat_prompts:Array[AiChatPrompt]):
		prompts.append_array(chat_prompts)

var chat_requests_history:Dictionary[String,RequestInfo] = {}

func generate_job_id(user_id:String, path_id:String) -> String:
	return "%s:%s" % [user_id,path_id]

func job_id_from_request(request:RequestInfo) -> String:
	return generate_job_id(request.user_id, request.path_id)

func got_a_previous_job_for(user_id:String, path_id:String) -> bool:
	var job_id:String = generate_job_id(user_id, path_id)
	return chat_requests_history.has(job_id)

func previous_job_finished(user_id:String, path_id:String) -> bool:
	var job_id:String = generate_job_id(user_id, path_id)
	if not chat_requests_history.has(job_id):
		return false
	var user_request:RequestInfo = chat_requests_history[job_id]
	return user_request.state == RequestState.Answered

class RequestInfo:
	var state:RequestState
	var request_path:DiscordRequestPath
	var path_id:String
	var user_id:String
	var data

	func _init(path:DiscordRequestPath, new_path_id:String, new_user_id:String, new_data):
		state = RequestState.WaitingForAnswer
		request_path = path
		path_id = new_path_id
		user_id= new_user_id
		data = new_data

class UserRequest:
	var info:RequestInfo
	var job:FactoryJob

func request_models_list():
	factory.request(AiListModelsRequest.new(), handle_list_models_response)

# TODO
# Make simple work specific agents
func dispatch_chat_request(
	user_id:String,
	path_id:String,
	model_prompts:Array[AiChatPrompt],
	model_name:String="",
	path:DiscordRequestPath = DiscordRequestPath.DiscordThread):

	var job_id:String = generate_job_id(user_id, path_id)
	var job_known:bool = chat_requests_history.has(job_id)

	if not model_name and not job_known:
		printerr("[BUG] No model name provided and unknown request")
		return

	var request_info:RequestInfo = chat_requests_history.get_or_add(
		job_id,
		RequestInfo.new(
			path, path_id, user_id,
			PromptHistory.new(model_name)))

	var prompts_history:PromptHistory = request_info.data as PromptHistory
	if prompts_history == null:
		printerr("[BUG] Expected the data of request info %s to be a PromptHistory !" % job_id)
		return

	prompts_history.append_all(model_prompts)

	var ai_chat_request := AiChatRequest.new(
		job_id,
		prompts_history.model_name,
		prompts_history.prompts)

	request_info.state = RequestState.WaitingForAnswer

	factory.request(ai_chat_request, handle_chat_request_response.bind(request_info))

func handle_list_models_response(job_response:AiListModelsResponse):
	models_list_received.emit(job_response.models)

func handle_chat_request_response(job_response:FactoryJobResponse, request_info:RequestInfo):
	print_debug("[DiscordCustomerAgent] Handle job response !")
	var path_id:String = request_info.path_id
	var response_type:String = ClassHelpers.get_class_of(job_response)
	print_debug("[DiscordCustomerAgent] %s received !" % response_type)
	match response_type:
		"AiChatResponse":
			var chat_response:AiChatResponse = job_response as AiChatResponse
			var original_content:String = chat_response.response
			var messages:PackedStringArray = DiscordHelpers.cut_messages_for_discord(original_content)

			var prompt_history = request_info.data as PromptHistory
			if chat_response.complete and prompt_history != null:
				prompt_history.append(AiChatPrompt.new(original_content, "assistant"))
			else:
				printerr("[BUG] Could not get the prompt history from the request ??")
			if request_info.request_path == DiscordRequestPath.DiscordThread:
				discord_bot.send_messages_in(path_id, messages)
			else:
				printerr("[BUG] Unhandled path %d" % request_info.request_path)
		"FactoryJobDone":
			request_info.state = RequestState.Answered
			if request_info.request_path == DiscordRequestPath.DiscordThread:
				discord_bot.send_message_in(path_id, "Job done !")
			else:
				printerr("[BUG] Unhandled path %d" % request_info.request_path)
	print_debug("Response handled !")
