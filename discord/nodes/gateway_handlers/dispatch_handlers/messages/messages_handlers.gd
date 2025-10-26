class_name DiscordMessageHandlers extends DiscordBotDispatchHandler

var handlers:Array[DiscordBotMessageHandler] = []

func register_handler(handler:DiscordBotMessageHandler) -> void:
	handlers.append(handler)

func get_dispatch_type() -> String:
	return "MESSAGE_CREATE"

func handle_dispatch(discord_bot:DiscordBot, dispatch_data:Dictionary):
	for handler in handlers:
		handler.handle_message(discord_bot, dispatch_data)
