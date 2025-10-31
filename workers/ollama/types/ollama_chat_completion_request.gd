class_name OllamaChatCompletionRequest extends OllamaRequest

@export var model:String
@export var messages:Array[Dictionary]
@export var tools:Array
@export var format:String
@export var options:Dictionary
@export var stream:bool
@export var keep_alive:int = 5*60

func add_prompt(prompt:AiChatPrompt):
	messages.append({"content": prompt.content, "role": prompt.role})

func to_dictionary() -> Dictionary:
	var dict:Dictionary = {
		"model": model,
		"messages": messages,
		"stream": stream}

	var fields := [
		[tools, "tools"],
		[format, "format"],
		[options, "options"]]

	for field_to_check in fields:
		var checked_field = field_to_check[0]
		var dict_key_name = field_to_check[1]
		if checked_field:
			dict[dict_key_name] = checked_field

	return dict
