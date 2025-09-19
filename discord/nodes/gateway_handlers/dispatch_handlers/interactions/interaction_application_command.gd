class_name DiscordBotApplicationCommandHandlers extends DiscordBotInteractionHandler

var handlers:Dictionary[String,DiscordBotApplicationCommandHandler] = {}

func get_interaction_type() -> DiscordBotGatewayInteractionHandlers.InteractionType:
	return DiscordBotGatewayInteractionHandlers.InteractionType.APPLICATION_COMMAND

func handle_interaction(discord_bot:DiscordBot, interaction_data:Dictionary) -> void:
	if not interaction_data.has("data"):
		printerr("[Discord Bot Application Command Handlers] Invalid data provided")
		return

	var command_data:Dictionary = interaction_data["data"]
	var command_name:String = command_data["name"]

	if not handlers.has(command_name):
		print_debug("Unhandled command name %s" % command_name)
		return

	var response:Dictionary = handlers[command_name].respond_to_command(command_data, interaction_data)
	if response != null:
		discord_bot.respond_to_interaction(interaction_data, response)

func register_command_name(command_name:String, handler:DiscordBotApplicationCommandHandler):
	handlers[command_name] = handler
