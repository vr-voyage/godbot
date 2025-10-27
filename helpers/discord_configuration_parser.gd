class_name DiscordConfigurationParser

const DISCORD_APP_ID:String = "DISCORD_APP_ID"
const DISCORD_TOKEN:String = "DISCORD_TOKEN"

static func parse_configuration_from_environment(env_file_path:String="") -> DiscordBotConfiguration:
	var config := DiscordBotConfiguration.new()
	var values_to_retrieve:PackedStringArray = [DISCORD_APP_ID, DISCORD_TOKEN]
	var environment_values:Dictionary = {}
	var got_them_all:bool = true
	var got_value:bool = false
	for value_to_retrieve in values_to_retrieve:
		got_value = OS.has_environment(value_to_retrieve)
		got_them_all = got_them_all && got_value
		if got_value:
			environment_values[value_to_retrieve] = OS.get_environment(value_to_retrieve)

	if not got_them_all:
		got_them_all = true
		var parsed_env_dict := EnvParser.parse_env_file(env_file_path)
		for value_to_retrieve in values_to_retrieve:
			if environment_values.has(value_to_retrieve) and environment_values[value_to_retrieve] != "":
				continue
			got_value = parsed_env_dict.has(value_to_retrieve)
			got_them_all = got_them_all && got_value
			if not got_value:
				continue
			environment_values[value_to_retrieve] = parsed_env_dict[value_to_retrieve]

	var missing_values:PackedStringArray = []
	if not got_them_all:
		for value_to_retrieve in values_to_retrieve:
			if not environment_values.has(value_to_retrieve) or not environment_values[value_to_retrieve]:
				missing_values.append(value_to_retrieve)

	if not missing_values.is_empty():
		printerr("Some values are missing : %s !" % ", ".join(missing_values))
		return null

	config.token = environment_values[DISCORD_TOKEN]
	config.application_id = environment_values[DISCORD_APP_ID]

	return config
