class_name ClassHelpers extends Node

static func get_class_of(obj:Variant) -> String:
	if obj == null:
		return "null"

	var script:Script = obj.get_script()
	if script == null:
		return type_string(typeof(obj))

	return script.get_global_name()
