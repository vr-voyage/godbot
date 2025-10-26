class_name OllamaModelPullRequest extends OllamaRequest

@export var model:String
@export var stream:bool = true
@export var insecure:bool = false

func to_dictionary() -> Dictionary:
	return {
		"model": model,
		"stream": stream,
		"insecure": insecure
	}
