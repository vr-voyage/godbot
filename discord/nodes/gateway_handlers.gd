extends Node

class_name DiscordBotGatewayHandlers

enum GatewayOpcode
{
	DISPATCH = 0,
	HEARTBEAT = 1,
	IDENTIFY = 2,
	PRESENCE_UPDATE = 3,
	VOICE_STATE_UPDATE = 4,
	RESUME = 6,
	RECONNECT = 7,
	REQUEST_GUILD_MEMBERS = 8,
	INVALID_SESSION = 9,
	HELLO = 10,
	HEARTBEAT_ACK = 11,
	REQUEST_SOUNDBOARD_SOUNDS = 31
}

var handlers:Dictionary[GatewayOpcode,DiscordBotGatewayHandler] = {}

func register_handler(opcode:GatewayOpcode, handler:DiscordBotGatewayHandler):
	handlers[opcode] = handler

func handle(discord_bot:DiscordBot, gateway_event_data):
	var opcode := gateway_event_data["op"] as int

	if handlers.has(opcode):
		handlers[opcode].handle(discord_bot, gateway_event_data)
		return

	print_debug("Unhandled opcode %d" % opcode)
