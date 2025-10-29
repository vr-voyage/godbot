extends DiscordBotApplicationCommandHandler

@export var discord_customer_agent:DiscordCustomerAgent

var known_models_list:Dictionary[String,AiModelDescription] = {}

func get_command_name() -> String:
	return "prompt"

func handle_received_models_list(models_list:Array[AiModelDescription]):
	print_debug("[DiscordBotPromptCommand] Handle received models list")
	for model in models_list:
		print_debug(model._to_string())
		known_models_list[model.internal_name] = model

func _ready():
	discord_customer_agent.models_list_received.connect(handle_received_models_list)
	discord_customer_agent.request_models_list()

func ai_model_description_to_option(model_description:AiModelDescription):
	return {
		"label": model_description.presentation_name,
		"value": model_description.internal_name,
		"description": model_description.description
	}

func add_known_models_to_modal(modal_content:Dictionary):
	var options_array:Array = modal_content["data"]["components"][0]["component"]["options"]
	for model_name in known_models_list:
		options_array.append(ai_model_description_to_option(known_models_list[model_name]))

func respond_to_command(_command_data:Dictionary, _interaction_data:Dictionary) -> Dictionary:
	var modal_content:Dictionary = {
		"type": DiscordTypes.InteractionCallback.MODAL,
		"data": {
			"custom_id": "prompt_modal",
			"title": "Prompt",
			"components": [
				{
					"type": DiscordTypes.Component.LABEL,
					"label": "Select the model you wish to use",
					"required": true,
					"component": {
						"type": DiscordTypes.Component.STRING_SELECT,
						"custom_id": "model_select",
						"placeholder": "Choose...",
						"options": []
					}
				},
				{
					"type": DiscordTypes.Component.LABEL,
					"label": "Prompt",
					"description": "Provide a full prompt for the AI to respond to :",
					"component": {
						"type": DiscordTypes.Component.TEXT_INPUT,
						"custom_id": "prompt",
						"style": DiscordTypes.TextInputStyle.PARAGRAPH,
						"min_length": 1,
						"max_length": 4000,
						"placeholder": "How to add a Hamster with kung-fu skills in Unity, using C#?",
						"required": true
					}
				}
			]
		}
	}
	add_known_models_to_modal(modal_content)
	return modal_content

func get_registration_json() -> Dictionary:
	return {
		"name": "prompt",
		"type": 1,
		"description": "Send a prompt to the AI"
	}
