class_name OllamaConfigurationParser

const OLLAMA_IP:String = "OLLAMA_IP"
const OLLAMA_PORT:String = "OLLAMA_PORT"

static func parse_configuration_from_environment(env_file_path:String="") -> OllamaConnectionConfiguration:
	var required_values:PackedStringArray = [OLLAMA_IP, OLLAMA_PORT]
	var env_keys:Dictionary = LocalEnvironment.get_values(required_values, env_file_path)
	if not env_keys.has_all(required_values):
		var missing_keys:PackedStringArray = DictionaryHelpers.get_missing_keys(
			required_values,
			env_keys)
		printerr("Missing required values : %s" % " ".join(missing_keys))
		return null

	var config := OllamaConnectionConfiguration.new()
	config.ip = env_keys[OLLAMA_IP]
	config.port = env_keys[OLLAMA_PORT]

	return config
