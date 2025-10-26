class_name AiChatRequest extends FactoryJob

@export var model:String = ""
@export var prompts:Array[AiChatPrompt]
@export var data:Dictionary[String,String] = {}

func _init(
	id_to_use:String,
	model_to_use:String,
	provided_prompts:Array[AiChatPrompt],
	added_data:Dictionary[String,String] = {}):
	id = id_to_use
	model = model_to_use
	prompts.append_array(provided_prompts)
	data = added_data

func _get_description() -> String:
	return "AiChatRequest"
