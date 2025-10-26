class_name DiscordBotModalSubmitHandlers extends DiscordBotInteractionHandler

var handlers:Dictionary[String,DiscordBotModalSubmitHandler] = {}

func get_interaction_type() -> DiscordTypes.Interaction:
	return DiscordTypes.Interaction.MODAL_SUBMIT

func handle_interaction(discord_bot:DiscordBot, interaction_data:Dictionary) -> void:
	if not interaction_data.has("data"):
		printerr("[Discord Bot Modal Submit Handlers] Invalid modal submit data provided")
		return

	var modal_submit_data:Dictionary = interaction_data["data"]
	var modal_submit_id:String = modal_submit_data["custom_id"]

	if not handlers.has(modal_submit_id):
		print_debug("Unhandled modal %s" % modal_submit_id)
		return

	var response:Dictionary = handlers[modal_submit_id].respond_to_modal_submit(modal_submit_data, interaction_data)
	if response != null:
		discord_bot.respond_to_interaction(interaction_data, response)

func register_modal_id(modal_id:String, handler:DiscordBotModalSubmitHandler):
	handlers[modal_id] = handler
