extends Node

class_name UiJsonDisplayAny

static var displayers:Dictionary[int,PackedScene] = {
	TYPE_ARRAY: preload("res://ui/json_types/ui_json_array.tscn") as PackedScene,
	TYPE_BOOL: preload("res://ui/json_types/ui_json_boolean.tscn") as PackedScene,
	TYPE_DICTIONARY: preload("res://ui/json_types/ui_json_dictionary.tscn") as PackedScene,
	TYPE_FLOAT: preload("res://ui/json_types/ui_json_number.tscn") as PackedScene,
	TYPE_INT: preload("res://ui/json_types/ui_json_number.tscn") as PackedScene,
	TYPE_NIL: preload("res://ui/json_types/ui_json_null.tscn") as PackedScene,
	TYPE_STRING: preload("res://ui/json_types/ui_json_string.tscn") as PackedScene
}

static func display(value, container):
	var value_type := typeof(value)
	var value_type_name := type_string(value_type)
	if not displayers.has(value_type):
		printerr("Cannot display value of type %s (%d)" % [value_type_name, value_type])
		return

	var display := displayers[value_type].instantiate()
	if display == null:
		printerr("Could not instantiate display of type %s (%d)" % [value_type_name, value_type])
		return

	container.add_child(display)
	display.display(value)
