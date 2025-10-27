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
var n_acks:int = 0

@export var http_requests_queue:HttpRequestsQueue

const debug_http_method_names:Array[String] = [
	"GET",
	"HEAD",
	"POST",
	"PUT",
	"DELETE",
	"OPTIONS",
	"TRACE",
	"CONNECT",
	"PATCH"
]

func print_to_curl(method:HTTPClient.Method, url:String, headers:PackedStringArray) -> void:
	var curl_command:String = "curl "
	if method >= 0 && method <= HTTPClient.METHOD_MAX:
		curl_command += "-X %s " % debug_http_method_names[method]

	for header in headers:
		curl_command += "-H '%s' " % header

	curl_command += url
	print_debug(curl_command)

func send_request(
	method:HTTPClient.Method,
	endpoint:String,
	data_sent,
	callback:Callable):
	var http_request:HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(callback)
	
	var url := "https://discord.com" + endpoint
	var data:String = JSON.stringify(data_sent) if data_sent != null else ""
	var headers:PackedStringArray = ["Authorization: Bot %s" % configuration.token]
	if method != HTTPClient.Method.METHOD_GET:
		headers.append("Content-Type: application/json")
	print_to_curl(method, url, headers)
	http_request.request(url, headers, method, data)


func restart_heartbeat_timer(time:float = -1):
	if time < 0 or is_inf(time) or is_nan(time):
		time = default_timer_value
	heartbeat_timer.start(time)

func send_heartbeat():
	if websocket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		return
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

	send_request(
		HTTPClient.METHOD_POST,
		"/api/v10/interactions/%s/%s/callback" % [interaction_id, interaction_token],
		response_data,
		callback)

func send_data(data):
	if websocket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		printerr("Cannot send data, websocket not open")
		return
	on_send_object.emit(data)
	var json_data:String = JSON.stringify(data)
	websocket.put_packet(json_data.to_utf8_buffer())
	on_data_sent.emit(json_data)

func _enter_tree():
	configuration = DiscordConfigurationParser.parse_configuration_from_environment()

func _ready():
	print_debug("Bot starting")
	if configuration == null:
		printerr("BOT NOT CONFIGURED !")
		get_tree().quit(1)
		return

	websocket.inbound_buffer_size = 512*1024
	websocket.outbound_buffer_size = 512*1024
	add_child(heartbeat_timer)
	heartbeat_timer.timeout.connect(send_heartbeat)

	connect_to_discord()
	set_process(true)
	print_debug("Bot started")
	timer_send_message_again = Timer.new()
	add_child(timer_send_message_again)
	timer_send_message_again.timeout.connect(send_current_message)
	timer_send_message_again.stop()


func connect_to_discord():
	if websocket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		websocket.close()

	websocket.connect_to_url("wss://gateway.discord.gg/?v=10&encoding=json")



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
			"intents": 0b1111111100010011,
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

func _cb_http_client_thread_created(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
	callback:Callable):
	if result != HTTPRequest.RESULT_SUCCESS:
		callback.call(false, "The HTTP Request failed with error %d" % result)
		return

	var content:String = body.get_string_from_utf8() if !body.is_empty() else ""
	if response_code > 400 or content.is_empty():
		callback.call(false, "Got the following response code %d - Content : %s" % [response_code, content])
		return

	var json_content = JSON.parse_string(content)
	if not json_content is Dictionary:
		callback.call(false, "Could not parse the provided answer : %s" % content)
		return

	var json_dict:Dictionary = json_content as Dictionary

	callback.call(true, json_dict)

class QueuedMessage:
	var channel_id:String
	var content:String

	func _init(channel:String, message:String):
		channel_id = channel
		content = message

var messages_to_send:Array[QueuedMessage] = []
var sending:bool = false
var timer_send_message_again:Timer

func send_current_message():
	sending = true
	print_debug("SEND CURRENT")
	if messages_to_send.is_empty():
		return

	var next_message:QueuedMessage = messages_to_send.front()

	# Just in case we got a weird message queued
	while next_message == null && messages_to_send:
		printerr("[BUG] A null message was queued !")
		messages_to_send.pop_front()
		next_message = messages_to_send.front()
	if next_message == null && messages_to_send.is_empty():
		sending = false
		return

	_send_message(next_message)

func mark_current_message_sent_and_send_next_message():
	print_debug("MARK CURRENT AS SENT")
	messages_to_send.pop_front()
	if messages_to_send.is_empty():
		sending = false
		return
	send_current_message()


func _handle_message_rate_limit(error_message:String):
	if error_message == null:
		print_debug("[BUG] The rate limit message was null ??")
		mark_current_message_sent_and_send_next_message()

	var json_error:Dictionary = JSON.parse_string(error_message) as Dictionary
	if json_error == null:
		print_debug("[BUG] The rate limit info could not be parsed (%s)" % error_message)
		mark_current_message_sent_and_send_next_message()

	if not json_error.has("retry_after"):
		print_debug("[BUG] Expected a 'retry_after' field in the JSON data")
		mark_current_message_sent_and_send_next_message()

	timer_send_message_again.start(json_error.get("retry_after") as float)

func _cb_http_client_message_created(
	_result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray):

	if response_code == 429:
		_handle_message_rate_limit(body.get_string_from_utf8())
		return

	var content:String = body.get_string_from_utf8()
	print_debug("[Message created result] %s" % content)

	if response_code > 400:
		printerr("[Message creation] Message creation failed :C")

	mark_current_message_sent_and_send_next_message()

func _send_message(queued_message:QueuedMessage):
	print_debug("SENDING MESSAGE : %s" % queued_message.content)
	send_request(
		HTTPClient.METHOD_POST,
		"/api/v10/channels/%s/messages" % queued_message.channel_id,
		{
			"content": queued_message.content,
		},
		_cb_http_client_message_created)

func send_message_in(channel_id:String, message:String):
	print_debug("Sending message...")
	send_messages_in(channel_id, [message])

func send_messages_in(channel_id:String, messages:PackedStringArray):
	print_debug("[DiscordBot] Sending %d messages to %s" % [len(messages), channel_id])
	for message in messages:
		messages_to_send.append(QueuedMessage.new(channel_id, message))

	if not sending:
		send_current_message()

func create_thread_in(channel_id:String, thread_title:String, callback:Callable):
	const PUBLIC_THREAD:int = 11
	var thread_data:Dictionary = {
		"name": thread_title,
		"auto_archive_duration": 1440,
		"type": PUBLIC_THREAD,
	}
	print_debug("Create thread : %s - %s" % [channel_id, thread_title])

	http_requests_queue.plan_request(
		callback,
		HTTPClient.METHOD_POST,
		"/api/v10/channels/%s/threads" % [channel_id],
		JSON.stringify(thread_data),
		get_http_headers())


func _cb_http_client_commands_response(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray):
	
	print_debug("[DiscordBot] Got commands list !")
	print_debug("Result : %d - Response code : %s\nResult %s" % [result, response_code, body.get_string_from_utf8()] )

func get_http_headers() -> Dictionary[String,String]:
	return {
		"Authorization": ("Bot %s" % configuration.token),
		"Content-Type": "application/json"
	}
