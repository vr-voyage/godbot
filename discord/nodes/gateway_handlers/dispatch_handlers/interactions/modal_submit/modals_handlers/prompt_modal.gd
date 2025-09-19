extends DiscordBotModalSubmitHandler

func get_modal_id() -> String:
	return "prompt_modal"

func respond_to_modal_submit(modal_data:Dictionary, _interaction_data:Dictionary) -> Dictionary:
	var modal_components:Array = modal_data["components"]
	var model_name:String = modal_components[0]["component"]["values"][0] as String
	var model_prompt:String = modal_components[1]["component"]["value"] as String
	return {
		"type": 4,
		"data": {
			"content": "You thought it was your stupidy Llama, but it was, I, GODOT ! So I don't care about your %s and your prompt:\n%s" % [model_name, model_prompt]
		}
	}
