@abstract class_name DiscordBotDispatchHandler extends Node

@abstract func get_dispatch_type() -> String
@abstract func handle_dispatch(discord_bot:DiscordBot, dispatch_data:Dictionary)

func _enter_tree():
	var dispatch_handlers := get_parent() as DiscordBotGatewayDispatchHandlers
	if dispatch_handlers == null:
		printerr("Expected parent to be a DiscordBotGatewayDispatchHandlers")
		return

	dispatch_handlers.register_dispatch_handler(get_dispatch_type(), self)
