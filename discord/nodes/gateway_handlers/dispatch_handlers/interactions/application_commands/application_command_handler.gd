@abstract class_name DiscordBotApplicationCommandHandler extends Node

@abstract func get_command_name() -> String
@abstract func respond_to_command(command_data:Dictionary, interaction_data:Dictionary) -> Dictionary
@abstract func get_registration_json() -> Dictionary

func _enter_tree():
	var handlers := get_parent() as DiscordBotApplicationCommandHandlers
	handlers.register_command_name(get_command_name(), self)
