extends DiscordBotGatewayHandler

func get_opcode() -> DiscordBotGatewayHandlers.GatewayOpcode:
	return DiscordBotGatewayHandlers.GatewayOpcode.HEARTBEAT_ACK

var _handler:Callable = first_time_handler

func first_time_handler(discord_bot:DiscordBot, _data) -> void:
	discord_bot.identify_ourselves()
	_handler = default_handler

func default_handler(_bot:DiscordBot, _data) -> void:
	print_debug("Heartbeat !")
	pass

func handle(discord_bot:DiscordBot, gateway_event_data):
	_handler.call(discord_bot, gateway_event_data)
