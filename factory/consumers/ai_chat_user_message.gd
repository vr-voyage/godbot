class_name DiscordAiChatUserMessage extends DiscordBotMessageHandler

@export var discord_customer_agent:DiscordCustomerAgent

func handle_message(discord_bot:DiscordBot, message:Dictionary):
	# TODO Some values are always here
	var thread_id:String = message["channel_id"]
	var user_id:String = message["author"]["id"]
	if not discord_customer_agent.got_a_previous_job_for(user_id, thread_id):
		return

	if not discord_customer_agent.previous_job_finished(user_id, thread_id):
		discord_bot.send_message_in(
			thread_id,
			"The bot is currently answering. No messages accepted at the moment")
		return

	discord_customer_agent.dispatch_chat_request(
		user_id,
		thread_id,
		[AiChatPrompt.new(message["content"])]) 
