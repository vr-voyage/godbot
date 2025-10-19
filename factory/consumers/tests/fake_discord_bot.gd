extends DiscordBot

func create_thread_in(channel_id:String, thread_title:String, callback:Callable):
	print_debug("Yeah ! Sure ! Totally made the thread %s in channel %s" % [thread_title, channel_id])
	var fake_channel_object:Dictionary = {"id": "124897521"}
	callback.call(true, fake_channel_object)

func send_message_in(channel_id:String, content:String):
	print_debug("Creating message %s in %s" %  [content, channel_id])

func send_messages_in(channel_id:String, messages:PackedStringArray):
	print_debug("Sending messages...")
	for message in messages:
		send_message_in(channel_id, message)

func _ready():
	pass

func _process(_delta):
	pass
