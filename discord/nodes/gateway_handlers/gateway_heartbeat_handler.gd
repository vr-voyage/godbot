extends DiscordBotGatewayHandler

func get_opcode() -> DiscordBotGatewayHandlers.GatewayOpcode:
	return DiscordBotGatewayHandlers.GatewayOpcode.HEARTBEAT

func handle(discord_bot:DiscordBot, _gateway_event_data):
	discord_bot.send_heartbeat()
