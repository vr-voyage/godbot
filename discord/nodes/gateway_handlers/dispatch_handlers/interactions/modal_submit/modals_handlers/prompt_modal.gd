extends DiscordBotModalSubmitHandler

@export var discord_customer_agent:DiscordCustomerAgent

func get_modal_id() -> String:
	return "prompt_modal"

func respond_to_modal_submit(modal_data:Dictionary, _interaction_data:Dictionary) -> Dictionary:
	var modal_components:Array = modal_data["components"]
	var model_name:String = modal_components[0]["component"]["values"][0] as String
	var model_prompt:String = modal_components[1]["component"]["value"] as String

	print_debug(JSON.stringify(modal_data))
	print_debug(JSON.stringify(_interaction_data))
	var chat_request := AiChatRequest.new("_", model_name, model_prompt)
	discord_customer_agent.handle_request(_interaction_data["member"]["user"]["id"], _interaction_data["channel"]["id"], chat_request)
	return {
		"type": 4,
		"data": { "content": "Your job has been taking into account" }
	}
