@abstract class_name DiscordBotGatewayHandler extends Node

@abstract func get_opcode() -> DiscordBotGatewayHandlers.GatewayOpcode
@abstract func handle(discord_bot:DiscordBot, gateway_event_data) -> void

func _enter_tree():
	var parent = get_parent() as DiscordBotGatewayHandlers
	if parent == null:
		printerr("Invalid parent !")
		return

	parent.register_handler(get_opcode(), self)
