@abstract class_name DiscordBotInteractionHandler extends Node

@abstract func get_interaction_type() -> DiscordTypes.Interaction
@abstract func handle_interaction(discord_bot:DiscordBot, interaction_data:Dictionary) -> void

func _enter_tree():
	var interaction_handlers := get_parent() as DiscordBotGatewayInteractionHandlers
	interaction_handlers.register_handler(get_interaction_type(), self)
