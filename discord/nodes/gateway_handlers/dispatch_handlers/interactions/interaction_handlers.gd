class_name DiscordBotGatewayInteractionHandlers extends DiscordBotDispatchHandler

enum InteractionType
{
	PING = 1,
	APPLICATION_COMMAND = 2,
	MESSAGE_COMPONENT = 3,
	APPLICATION_COMMAND_AUTOCOMPLETE = 4,
	MODAL_SUBMIT = 5
}

var handlers:Dictionary[InteractionType,DiscordBotInteractionHandler] = {}

func register_handler(interactionType:InteractionType, handler:DiscordBotInteractionHandler) -> void:
	handlers[interactionType] = handler

func get_dispatch_type() -> String:
	return "INTERACTION_CREATE"

func handle_dispatch(discord_bot:DiscordBot, dispatch_data:Dictionary):
	var dispatch_type := dispatch_data["type"] as int
	if handlers.has(dispatch_type):
		handlers[dispatch_type].handle_interaction(discord_bot, dispatch_data)
