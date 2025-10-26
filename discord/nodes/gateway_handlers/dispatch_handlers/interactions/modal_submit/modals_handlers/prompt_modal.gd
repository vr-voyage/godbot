extends DiscordBotModalSubmitHandler

@export var discord_customer_agent:DiscordCustomerAgent
@export var discord_bot:DiscordBot

class DiscordAiChatRequest:
	var modal_data:Dictionary = {}
	var interaction_data:Dictionary = {}
	var prompts:Array[AiChatPrompt] = []
	var model_name:String = ""

	func _setup_object_with_request() -> void:
		var modal_components:Array = modal_data["components"]

		model_name = modal_components[0]["component"]["values"][0] as String
		var model_prompt:String = modal_components[1]["component"]["value"] as String

		prompts.append(AiChatPrompt.new(model_prompt))

	func _init(modal:Dictionary, interaction:Dictionary):
		modal_data = modal
		interaction_data = interaction
		_setup_object_with_request()

	func get_interaction_token() -> String:
		return interaction_data["token"]

	func get_requesting_user_id() -> String:
		return interaction_data["member"]["user"]["id"]

	func get_channel_id_where_to_create_thread() -> String:
		return interaction_data["channel"]["id"]

	const THREAD_TITLE_SIZE:int = 100
	func get_thread_title() -> String:
		for prompt in prompts:
			if prompt.role == "user":
				var prompt_first_line:String = prompt.content.split('\n')[0]
				var thread_title:String = "%s - %s" % [model_name, prompt_first_line]
				return thread_title.substr(0, THREAD_TITLE_SIZE)
		return ""

var chat_requests_from_discord:Array[DiscordAiChatRequest] = []

func _cb_thread_created(http_response:HTTPResponse, request:DiscordAiChatRequest):
	var body:String = http_response.body.get_string_from_utf8()
	if !http_response.success:
		# TODO Better error handling. Inform the user is possible
		printerr("Thread creation for /prompt command failed. (%d - %d - %s)" % [
			http_response.godot_code, http_response.http_code, body
		])
		return

	var json_thread_response_raw = JSON.parse_string(body)
	if not json_thread_response_raw is Dictionary:
		printerr("[BUG] Unhandled response from Discord : %s" % body)
		return

	var json_thread_response:Dictionary = json_thread_response_raw as Dictionary

	var thread_id:String = json_thread_response["id"]

	discord_customer_agent.dispatch_chat_request(
		request.get_requesting_user_id(),
		thread_id,
		request.prompts,
		request.model_name)

func prepare_for_next_request():
	if chat_requests_from_discord.is_empty():
		set_process(false)
		return

	var ai_chat_request:DiscordAiChatRequest = chat_requests_from_discord.pop_front()
	if ai_chat_request == null:
		printerr("[BUG] AI Chat request was null !")
		return

	var channel_id:String = ai_chat_request.get_channel_id_where_to_create_thread()
	var thread_title:String = ai_chat_request.get_thread_title()

	discord_bot.create_thread_in(channel_id, thread_title, _cb_thread_created.bind(ai_chat_request))

func _process(_delta):
	prepare_for_next_request()

func add_request(request:DiscordAiChatRequest):
	chat_requests_from_discord.append(request)
	set_process(true)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)

func get_modal_id() -> String:
	return "prompt_modal"

func respond_to_modal_submit(modal_data:Dictionary, interaction_data:Dictionary) -> Dictionary:
	print_debug(JSON.stringify(modal_data))
	print_debug(JSON.stringify(interaction_data))

	add_request(DiscordAiChatRequest.new(modal_data, interaction_data))

	return {
		"type": 4,
		"data": { "content": "Your job has been taking into account", "flags": DiscordTypes.MessageFlag.EPHEMERAL }
	}
