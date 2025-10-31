class_name OpenAiChatResponse extends Resource

@export var choices:Array[AiChatPrompt]

static func from_v1_json(json_raw:String) -> OpenAiChatResponse:
	var parsed_json = JSON.parse_string(json_raw)
	if not parsed_json is Dictionary:
		printerr("[OpenAiChatResponse:from_v1_json] Expected a Dictionary, got a %s" % type_string(typeof(parsed_json)))
		return null

	var json:Dictionary = parsed_json
	if not json.has_all(["choices"]):
		printerr("[OpenAiChatResponse:from_v1_json] No choices provided")
		return null

	var choices_raw = json["choices"]
	if not choices_raw is Array:
		printerr("[OpenAiChatResponse:from_v1_json] 'choices' was not an array")
		return null

	var response := OpenAiChatResponse.new()
	var provided_choices:Array = choices_raw
	for choice in provided_choices:
		if not choice is Dictionary:
			continue
		if not choice.has("message"):
			continue

		var message_raw = choice["message"]
		if not message_raw is Dictionary:
			continue
		var message:Dictionary = message_raw
		if not message.has_all(["role", "content"]):
			continue
		response.choices.append(AiChatPrompt.new(message["content"], message["role"]))
	return response
