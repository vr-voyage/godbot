extends DiscordBotApplicationCommandHandler

func get_command_name() -> String:
	return "test"

func respond_to_command(command_data:Dictionary, interaction_data:Dictionary) -> Dictionary:
	print_debug(JSON.stringify(command_data, "\t"))
	print_debug(JSON.stringify(interaction_data, "\t"))
	return {
		"type": 4,
		"data": { "content": "Test Test Teeeest" }
	}

func get_registration_json() -> Dictionary:
	return {
		"name": "test",
		"type": 1,
		"description": "Test command"
	}
