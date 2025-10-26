class_name DiscordBotGatewayInteractionHandlers extends DiscordBotDispatchHandler

var handlers:Dictionary[DiscordTypes.Interaction,DiscordBotInteractionHandler] = {}

func register_handler(interactionType:DiscordTypes.Interaction, handler:DiscordBotInteractionHandler) -> void:
	handlers[interactionType] = handler

func get_dispatch_type() -> String:
	return "INTERACTION_CREATE"

func handle_dispatch(discord_bot:DiscordBot, dispatch_data:Dictionary):
	var dispatch_type := dispatch_data["type"] as int
	if handlers.has(dispatch_type):
		handlers[dispatch_type].handle_interaction(discord_bot, dispatch_data)
