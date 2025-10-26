class_name AiChatPrompt extends Resource

@export var role:String = "user"
@export var content:String = ""

func _init(new_content:String, new_role:String = "user"):
	content = new_content
	role = new_role
