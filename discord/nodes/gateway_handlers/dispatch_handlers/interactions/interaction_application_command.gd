class_name DiscordBotApplicationCommandHandlers extends DiscordBotInteractionHandler

@export var discord_bot:DiscordBot
@export var http_request_queue:HttpRequestsQueue
@export var cleanup_commands_on_start:bool

var handlers:Dictionary[String,DiscordBotApplicationCommandHandler] = {}

func get_interaction_type() -> DiscordTypes.Interaction:
	return DiscordTypes.Interaction.APPLICATION_COMMAND

func _ready():
	if cleanup_commands_on_start:
		# Rename the methods... this is weird
		_get_commands_list()

func _cb_get_commands_list(http_response:HTTPResponse):
	if not http_response.success:
		printerr("[ApplicationCommands] Something went wrong when trying to get the commands")
		return

	var body_string:String = http_response.body.get_string_from_utf8()
	if body_string == null:
		printerr("[ApplicationCommands] Discord didn't give a back a useable string for the commands list")
		return

	var commands_list_raw = JSON.parse_string(body_string)
	if not commands_list_raw is Array:
		printerr("[ApplicationCommands] Expected a JSON array for the commands list, got %s" % body_string)
		return

	var commands_list:Array = commands_list_raw as Array
	for command_description_raw in commands_list:
		if not command_description_raw is Dictionary:
			continue

		var command_description:Dictionary = command_description_raw as Dictionary
		if not command_description.has_all(["name", "id"]):
			continue

		var command_name:String = command_description["name"] as String
		if command_name == null:
			continue

		print_debug("[ApplicationCommands] Commands list : /%s" % command_name)

		if handlers.has(command_name):
			print_debug("[ApplicationCommands] /%s : Already managed internally" % command_name)
			continue

		var command_id:String = command_description["id"] as String
		if command_id == null:
			continue

		_delete_command(command_id)

func _delete_command(command_id:String):
	print_debug("[ApplicationCommands] Deleting command %s" % command_id)
	http_request_queue.plan_request(
		_cb_delete_command,
		HTTPClient.Method.METHOD_DELETE,
		"/api/v10/applications/%s/commands/%s" % [discord_bot.configuration.application_id, command_id],
		"",
		discord_bot.get_http_headers())

func _cb_delete_command(http_response:HTTPResponse):
	if not http_response.success:
		print_debug("[ApplicationCommands] Something went wrong when trying to delete a command ! %s - %s" % [http_response.godot_code, http_response.http_code])

func _get_commands_list():
	http_request_queue.plan_request(
		_cb_get_commands_list,
		HTTPClient.Method.METHOD_GET,
		"/api/v10/applications/%s/commands" % discord_bot.configuration.application_id,
		"",
		discord_bot.get_http_headers())

func handle_interaction(local_bot:DiscordBot, interaction_data:Dictionary) -> void:
	if not interaction_data.has("data"):
		printerr("[Discord Bot Application Command Handlers] Invalid data provided")
		return

	var command_data:Dictionary = interaction_data["data"]
	var command_name:String = command_data["name"]

	if not handlers.has(command_name):
		print_debug("[ApplicationCommands] Unhandled command name /%s" % command_name)
		return

	var response:Dictionary = handlers[command_name].respond_to_command(command_data, interaction_data)
	if response != null:
		local_bot.respond_to_interaction(interaction_data, response)

func register_command_name(command_name:String, handler:DiscordBotApplicationCommandHandler):
	handlers[command_name] = handler
	_register_command_on_discord(command_name, handler.get_registration_json())

func _cb_register_command(http_response:HTTPResponse, command_name:String):
	var body_string:String = http_response.body.get_string_from_utf8()
	if not http_response.success:
		printerr("[ApplicationCommands] /%s : Registration failed (%s)" % [command_name, body_string])
		return

	print_debug("[ApplicationCommands] /%s : Registration complete" % command_name)

func _register_command_on_discord(command_name:String, command_registration_data:Dictionary):
	print_debug("[ApplicationCommands] /%s : Registering..." % command_name)
	http_request_queue.plan_request(
		_cb_register_command.bind(command_name),
		HTTPClient.Method.METHOD_POST,
		"/api/v10/applications/%s/commands" % discord_bot.configuration.application_id,
		JSON.stringify(command_registration_data),
		discord_bot.get_http_headers())
