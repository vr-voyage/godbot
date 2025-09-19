@abstract class_name DiscordBotModalSubmitHandler extends Node

@abstract func get_modal_id() -> String
@abstract func respond_to_modal_submit(modal_data:Dictionary, interaction_data:Dictionary) -> Dictionary

func _enter_tree():
	var handlers := get_parent() as DiscordBotModalSubmitHandlers 
	if handlers == null:
		printerr("Expected to be a child of DiscordBotModalSubmitHandlers")
		queue_free()

	handlers.register_modal_id(get_modal_id(), self)
