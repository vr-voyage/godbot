extends UiJsonDisplay

@export var array_value_display:PackedScene
@export var values_container:Container

func display(value):
	var arr:Array = value as Array
	if arr == null:
		return

	var n_values := len(arr)
	for i in range(0,n_values):
		var display_element := array_value_display.instantiate()
		values_container.add_child(display_element)
		display_element.display_array_value(i, arr[i])
