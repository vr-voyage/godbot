class_name EnvParser

const comment_character:String = "#"

static func _find_comment_start(line:String) -> int:
	var comment_character_index:int = line.find(comment_character)
	while comment_character_index >= 0:
		var previous_index:int = comment_character_index - 1
		if previous_index < 0:
			break
		if line[previous_index] != "\\":
			break
		comment_character_index = line.find(comment_character, comment_character_index+1)

	return comment_character_index

static func _remove_comments_in(lines:PackedStringArray):
	var n_lines:int = len(lines)
	for line_index in range(0, n_lines):
		var line:String = lines[line_index]
		var comment_start:int = _find_comment_start(line)
		if comment_start < 0:
			continue
		lines[line_index] = line.substr(0, comment_start)

static func parse_env_content(env_file_content:String) -> Dictionary:
	var env_dict:Dictionary = {}
	if not env_file_content:
		return env_dict

	var lines:PackedStringArray = env_file_content.split("\n")
	_remove_comments_in(lines)
	
	for line in lines:
		var cleaned_line:String = line.strip_edges()
		var key_values:PackedStringArray = cleaned_line.split("=",true,2)
		if len(key_values) < 2:
			continue
		var key:String = key_values[0].strip_edges()
		var value:String = key_values[1].strip_edges()
		env_dict[key] = value
	return env_dict

static func parse_env_file(file_path:String = "") -> Dictionary:
	if file_path == "":
		file_path = ".env"
	return(parse_env_content(FileAccess.get_file_as_string(file_path)))
