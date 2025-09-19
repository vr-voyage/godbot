extends Node

class_name DiscordBot

@export var configuration:DiscordBotConfiguration

signal on_data_received(received_data:String)
signal on_data_sent(sent_data:String)

signal on_object_received(received_object)
signal on_send_object(object_to_send)

@export var gateway_handlers:DiscordBotGatewayHandlers

var websocket:WebSocketPeer = WebSocketPeer.new()
var last_sequence = null

var heartbeat_timer:Timer = Timer.new()
var default_timer_value:float = 42.5

func restart_heartbeat_timer(time:float = -1):
	if time < 0 or is_inf(time) or is_nan(time):
		time = default_timer_value
	heartbeat_timer.start(time)

func send_heartbeat():
	send_data({"op": 1, "d": last_sequence})
	restart_heartbeat_timer()

func interaction_response(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray):
	print_debug("Result : %d, Code : %d, body: %s" % [result, response_code, body.get_string_from_utf8()])

func respond_to_interaction(interaction_data:Dictionary, response_data:Dictionary, callback:Callable = interaction_response) -> void:
	var interaction_id:String = interaction_data["id"] as String
	var interaction_token:String = interaction_data["token"] as String
	var http_request:HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(callback)
	
	var url := "https://discord.com/api/v10/interactions/%s/%s/callback" % [interaction_id, interaction_token]
	var data := JSON.stringify(response_data)
	var headers:PackedStringArray = [
		"Content-Type: application/json",
		"Authorization: Bot %s" % configuration.token]
	print_debug("URL : %s, data : %s" % [url, data])
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, data)

func response_interaction_prompt_modal(interaction_data: Dictionary, modal_data: Dictionary) -> void:
	var modal_components:Array = modal_data["components"]
	var model_name:String = modal_components[0]["component"]["values"][0] as String
	var model_prompt:String = modal_components[1]["component"]["value"] as String
	var response_message:Dictionary = {
		"type": 4,
		"data": {
			"content": "You thought it was your stupidy Llama, but it was, I, GODOT ! So I don't care about your %s and your prompt:\n%s" % [model_name, model_prompt]
		}
	}
	respond_to_interaction(interaction_data, response_message, interaction_response)
	pass

func send_data(data):
	if websocket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		printerr("Cannot send data, websocket not open")
		return
	on_send_object.emit(data)
	var json_data:String = JSON.stringify(data)
	websocket.put_packet(json_data.to_utf8_buffer())
	on_data_sent.emit(json_data)

func _ready():
	print_debug("Bot starting")
	if configuration == null:
		printerr("BOT NOT CONFIGURED !")
		return

	websocket.inbound_buffer_size = 512*1024
	websocket.outbound_buffer_size = 512*1024
	add_child(heartbeat_timer)
	heartbeat_timer.timeout.connect(send_heartbeat)

	connect_to_discord()
	set_process(true)
	print_debug("Bot started")

func connect_to_discord():
	if websocket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		websocket.close()

	websocket.connect_to_url("wss://gateway.discord.gg/?v=10&encoding=json")

var n_acks:int = 0

func parse_packet_content(content:String):
	on_data_received.emit(content)
	var command_content := JSON.parse_string(content) as Dictionary
	if command_content == null:
		printerr("parse_packet_content", "Could not parse content !")
		return

	on_object_received.emit(command_content)

	if !command_content.has_all(["op"]):
		printerr("parse_packet_content", "Invalid packet. Missing the 'op' field")
		return

	if command_content.has("s"):
		var seq = command_content["s"]
		if seq != null:
			last_sequence = seq as int

	gateway_handlers.handle(self, command_content)

func identify_ourselves():
	var identification:Dictionary = {
		"op": 2,
		"d": {
			"token": configuration.token,
			"intents": 0b11111100010011,
			"properties": {
				  "os": "windows",
				  "browser": "godot",
				  "device": "desktop"
			}
	 	}
	}
	send_data(identification)

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	websocket.poll()


	# get_ready_state() tells you what state the socket is in.
	var state = websocket.get_ready_state()

	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		while websocket.get_available_packet_count():
			var packet_content:String = websocket.get_packet().get_string_from_utf8()
			#print_debug("websocket", "Got data from server: %s" % packet_content)
			parse_packet_content(packet_content)

	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		print_debug("websocket", "Websocket is clooosinnnng")

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = websocket.get_close_code()
		var reason = websocket.get_close_reason()
		print_debug("websocket", "WebSocket closed with code: %d (%s). Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.
