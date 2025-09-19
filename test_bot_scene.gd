extends Node

@export var log_display:Label
@export var objects_display:Container


func _on_node_on_data_received(_received_data):
	pass
	#print_debug("_on_node_on_data_received")
	#log_display.text += "-> %s\n" % str(received_data)

func _on_node_on_data_sent(_sent_data):
	pass
	#print_debug("_on_node_on_data_sent")
	#log_display.text += "<- %s\n" % str(sent_data)

func _on_node_on_object_received(_received_object):
	pass
	#print_debug("_on_node_on_object_received")
	#UiJsonDisplayAny.display(received_object, objects_display)

func _on_node_on_send_object(_object_to_send):
	pass
	#print_debug("_on_node_on_send_object")
	#UiJsonDisplayAny.display(object_to_send, objects_display)
