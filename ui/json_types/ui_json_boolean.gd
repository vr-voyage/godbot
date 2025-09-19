extends UiJsonDisplay

func display(value):
	if value is bool:
		%True.visible = value
		%False.visible = !value
