class_name AiModelDescription extends Resource

## The internal name used by the engines. Example "gemma3:1b"
@export var internal_name:String
## The external name presented to the user. Example "Gemma 3 (1B)"
@export var presentation_name:String
## The description of that model.
@export var description:String

func _to_string():
	return "Internal : %s, Presentation : %s, Description : %s" % [internal_name, presentation_name, description]
