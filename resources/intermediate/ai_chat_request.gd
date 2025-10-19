class_name AiChatRequest extends FactoryJob

@export var model:String = ""
@export var user_prompt:String = ""
@export var system_prompt:String = ""
@export var data:Dictionary[String,String] = {}

func _init(id_to_use:String, model_to_use:String, prompt:String, added_data:Dictionary[String,String] = {}, system_prompt_to_use = ""):
	id = id_to_use
	model = model_to_use
	user_prompt = prompt
	data = added_data
	system_prompt = system_prompt_to_use

func _get_description() -> String:
	return "Chat : %s - %s" % [model, user_prompt]
