extends UiJsonDisplay

@export var dictionary_value_display:PackedScene
@export var values_container:Container

func display(value):
	var dict:Dictionary = value as Dictionary
	if dict == null:
		return

	for key in dict:
		var kv_display := dictionary_value_display.instantiate()
		values_container.add_child(kv_display)
		kv_display.display_key_value(key, dict[key])
