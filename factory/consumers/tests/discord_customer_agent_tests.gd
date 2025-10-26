extends Control

@export var discord_customer_agent:DiscordCustomerAgent

@export var debug_output:TextEdit

func test_long_text_cut():
	var content:String = FileAccess.get_file_as_string(r"")
	if content == null:
		printerr("Could not open the file")
		return

	var messages:PackedStringArray = discord_customer_agent.cut_messages_for_discord(content)
	for message in messages:
		debug_output.text += message

func list_models_response(response:AiListModelsResponse):
	for model in response.models:
		print_debug(model.internal_name)


func _ready():
	#var ai_chat_request:AiChatRequest = AiChatRequest.new("FEIZJPO", "gemma3:1b", [AiChatPrompt.new("Can hamsters do taekwondo ?")])

	var request_path := DiscordCustomerAgent.DiscordRequestPath.DiscordThread
	var user_id := "userA"
	var path_id := "threadB"
	var model_name := "gemma3:1b"
	
	var previous_answer:String = FileAccess.get_file_as_string("res://factory/consumers/tests/example_response.txt",)
	var prompt_history := DiscordCustomerAgent.PromptHistory.new(
		model_name,
		[
			AiChatPrompt.new("Can hamsters do taekwondo ?"),
			AiChatPrompt.new(previous_answer, "assistant")
		]
	)
	var job_id:String = discord_customer_agent.generate_job_id(user_id, path_id)
	var current_jobs := discord_customer_agent.chat_requests_history
	var previous_request := DiscordCustomerAgent.RequestInfo.new(
		request_path,
		path_id,
		user_id,
		prompt_history)
	current_jobs[job_id] = previous_request

	discord_customer_agent.dispatch_chat_request(
		user_id,
		path_id,
		[AiChatPrompt.new("Yes, tell me more about that Kinetic Theory")],
		model_name)
	#test_long_text_cut()
	#discord_customer_agent.models_list_received.connect(list_models_response)
	#discord_customer_agent.request_models_list()
