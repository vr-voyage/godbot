class_name VllmConfigurationParser

const VLLM_IP:String = "VLLM_IP"
const VLLM_PORT:String = "VLLM_PORT"

# TODO Find a way to factorize this with the other almost identical parsers...
static func parse_configuration_from_environment(env_file_path:String="") -> VllmConnectionConfiguration:
	var required_values:PackedStringArray = [VLLM_IP, VLLM_PORT]
	var env_keys:Dictionary = LocalEnvironment.get_values(required_values, env_file_path)
	if not env_keys.has_all(required_values):
		var missing_keys:PackedStringArray = DictionaryHelpers.get_missing_keys(
			required_values,
			env_keys)
		printerr("Missing required values : %s" % " ".join(missing_keys))
		return null

	var config := VllmConnectionConfiguration.new()
	config.ip = env_keys[VLLM_IP]
	config.port = env_keys[VLLM_PORT]

	return config
