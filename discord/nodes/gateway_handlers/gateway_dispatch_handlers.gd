class_name DiscordBotGatewayDispatchHandlers extends DiscordBotGatewayHandler

var handlers:Dictionary[String,DiscordBotDispatchHandler] = {}

func get_opcode() -> DiscordBotGatewayHandlers.GatewayOpcode:
	return DiscordBotGatewayHandlers.GatewayOpcode.DISPATCH

func handle(discord_bot:DiscordBot, gateway_event_data:Dictionary):
	var dispatch_type:String = str(gateway_event_data.get("t", ""))
	if handlers.has(dispatch_type):
		handlers[dispatch_type].handle_dispatch(discord_bot, gateway_event_data["d"] as Dictionary)
		return
	print_debug("Unhandled dispatch type %s" % dispatch_type)

func register_dispatch_handler(dispatch_type:String, handler:DiscordBotDispatchHandler):
	handlers[dispatch_type] = handler
