extends DiscordBotApplicationCommandHandler

func get_command_name() -> String:
	return "prompt"

func respond_to_command(_command_data:Dictionary, _interaction_data:Dictionary) -> Dictionary:
	var modal_content:Dictionary = {
		"type": 9,
		"data": {
			"custom_id": "prompt_modal",
			"title": "Prompt",
			"components": [
				{
					"type": 18,
					"label": "Select the model",
					"required": true,
					"component": {
						"type": 3,
						"custom_id": "model_select",
						"placeholder": "Choose...",
						"options": [
							{
								"label": "Gemma3 (1B)",
								"value": "gemma3:1b",
								"description": "The idiot",
								"emoji": {
									"name": "🌤"
								}
							}
						]
					}
				},
				{
					"type": 18,
					"label": "Prompt",
					"description": "Provider a full prompt for the AI to respond to.",
					"component": {
						"type": 4,
						"custom_id": "prompt",
						"style": 2,
						"min_length": 1,
						"max_length": 4000,
						"placeholder": "How to add a Hamster with kung-fu skills in Unity, using C#?",
						"required": true
					}
				}
			]
		}
	}
	return modal_content

func get_registration_json() -> Dictionary:
	return {
		"name": "prompt",
		"type": 1,
		"description": "Send a prompt to the AI"
	}
