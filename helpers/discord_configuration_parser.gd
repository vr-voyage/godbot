class_name DiscordConfigurationParser

const DISCORD_APP_ID:String = "DISCORD_APP_ID"
const DISCORD_TOKEN:String = "DISCORD_TOKEN"

static func parse_configuration_from_environment(env_file_path:String="") -> DiscordBotConfiguration:
	var required_values:PackedStringArray = [DISCORD_APP_ID, DISCORD_TOKEN]
	var env_keys:Dictionary = LocalEnvironment.get_values(required_values, env_file_path)
	if not env_keys.has_all(required_values):
		var missing_keys:PackedStringArray = DictionaryHelpers.get_missing_keys(
			required_values,
			env_keys)
		printerr("Missing required values : %s" % " ".join(missing_keys))
		return null

	var config := DiscordBotConfiguration.new()
	config.token = env_keys[DISCORD_TOKEN]
	config.application_id = env_keys[DISCORD_APP_ID]

	return config
