class_name LocalEnvironment

static func get_values_from_os_env(keys:PackedStringArray) -> Dictionary:
	var ret = {}
	for key in keys:
		if OS.has_environment(key):
			ret[key] = OS.get_environment(key)
	return ret

static func get_values(keys:PackedStringArray, env_file_path:String = "") -> Dictionary:
	var env_file_content:Dictionary = EnvParser.parse_env_file(env_file_path)
	var environment_content:Dictionary = get_values_from_os_env(keys)
	environment_content.merge(env_file_content, false)
	return environment_content
