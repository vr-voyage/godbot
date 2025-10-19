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

func _ready():
	#var ai_chat_request:AiChatRequest = AiChatRequest.new("FEIZJPO", "gemma3:1b", "Can hamsters do taekwondo ?")
	#discord_customer_agent.handle_request("userA", "channelB", ai_chat_request)
	test_long_text_cut()
