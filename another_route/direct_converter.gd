extends Node

# Abandonned
# Reason : Queue-ing is hell

class Converter:
	var fields_mapping:Dictionary[String,String] = {}
	var callback:Callable
	pass

var converters:Dictionary[String,Dictionary] = {}
@export var ollama_endpoints:OllamaEndpoints

func direct_conversion(_action_name:String, _args:Dictionary):
	pass
