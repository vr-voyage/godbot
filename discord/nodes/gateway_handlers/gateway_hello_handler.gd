extends DiscordBotGatewayHandler

func get_opcode() -> DiscordBotGatewayHandlers.GatewayOpcode:
	return DiscordBotGatewayHandlers.GatewayOpcode.HELLO

func handle(discord_bot:DiscordBot, gateway_event_data):
	print_debug("HELLO !")
	var d:Dictionary = gateway_event_data["d"] as Dictionary
	var hearbeat_interval_ms := (d["heartbeat_interval"] as float) / 1000.0
	var first_heartbeat := hearbeat_interval_ms * randf()
	discord_bot.default_timer_value = hearbeat_interval_ms
	discord_bot.restart_heartbeat_timer(first_heartbeat)
