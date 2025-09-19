extends Container

@export var ui_key:Label

func display_key_value(key, value):
	ui_key.text = str(key)
	UiJsonDisplayAny.display(value, self)
