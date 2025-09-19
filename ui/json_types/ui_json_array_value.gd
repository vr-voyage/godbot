extends Container

class_name UiJsonArrayValueDisplay

@export var ui_index:Label
@export var container:Container

func display_array_value(index:int, value) -> void:
	ui_index.text = str(index)
	UiJsonDisplayAny.display(value, container)
