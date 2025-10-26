@abstract class_name DiscordBotMessageHandler extends Node

@abstract func handle_message(discord_bot:DiscordBot, message:Dictionary)

func _enter_tree():
	var interaction_handlers := get_parent() as DiscordMessageHandlers
	interaction_handlers.register_handler(self)
