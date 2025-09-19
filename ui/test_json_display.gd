extends PanelContainer

@export var container:Container

var json:Array = [
	{
		"id": "1411691239363051598",
		"application_id": "1411684728230248448",
		"version": "1412827313502158939",
		"default_member_permissions": null,
		"type": 1,
		"name": "thread",
		"description": "creates a thread and mentions user",
		"dm_permission": true,
		"contexts": null,
		"integration_types": [
			0,
			1
		],
		"options": [
			{
				"type": 3,
				"name": "title",
				"description": "The thread title",
				"required": true
			}
		],
		"nsfw": false
	},
	{
		"id": "1411691240725942414",
		"application_id": "1411684728230248448",
		"version": "1411691240725942415",
		"default_member_permissions": null,
		"type": 1,
		"name": "private-thread",
		"description": "creates a private thread and mentions user",
		"dm_permission": true,
		"contexts": null,
		"integration_types": [
			0,
			1
		],
		"nsfw": false
	},
	{
		"id": "1411691242118578386",
		"application_id": "1411684728230248448",
		"version": "1411691242118578387",
		"default_member_permissions": null,
		"type": 1,
		"name": "message-stream",
		"description": "change preference on message streaming from ollama. WARNING: can be very slow due to Discord limits.",
		"dm_permission": true,
		"contexts": null,
		"integration_types": [
			0,
			1
		],
		"options": [
			{
				"type": 5,
				"name": "stream",
				"description": "enable or disable message streaming",
				"required": true
			}
		],
		"nsfw": false
	},
	{
		"id": "1411691243624333435",
		"application_id": "1411684728230248448",
		"version": "1411691243624333436",
		"default_member_permissions": null,
		"type": 1,
		"name": "toggle-chat",
		"description": "toggle all chat features. Adminstrator Only.",
		"dm_permission": true,
		"contexts": null,
		"integration_types": [
			0,
			1
		],
		"options": [
			{
				"type": 5,
				"name": "enabled",
				"description": "true = enabled, false = disabled",
				"required": true
			}
		],
		"nsfw": false
	},
	{
		"id": "1411691245226557450",
		"application_id": "1411684728230248448",
		"version": "1411691245226557451",
		"default_member_permissions": null,
		"type": 1,
		"name": "shutoff",
		"description": "shutdown the bot. You will need to manually bring it online again. Administrator Only.",
		"dm_permission": true,
		"contexts": null,
		"integration_types": [
			0,
			1
		],
		"nsfw": false
	},
	{
		"id": "1411691325681565796",
		"application_id": "1411684728230248448",
		"version": "1411691325681565797",
		"default_member_permissions": null,
		"type": 1,
		"name": "modify-capacity",
		"description": "maximum amount messages bot will hold for context.",
		"dm_permission": true,
		"contexts": null,
		"integration_types": [
			0,
			1
		],
		"options": [
			{
				"type": 10,
				"name": "context-capacity",
				"description": "number of allowed messages to remember",
				"required": true
			}
		],
		"nsfw": false
	},
	{
		"id": "1411691327808344098",
		"application_id": "1411684728230248448",
		"version": "1411691327808344099",
		"default_member_permissions": null,
		"type": 1,
		"name": "clear-user-channel-history",
		"description": "clears history for user in the current channel",
		"dm_permission": true,
		"contexts": null,
		"integration_types": [
			0,
			1
		],
		"nsfw": false
	},
	{
		"id": "1411691330111016970",
		"application_id": "1411684728230248448",
		"version": "1411691330111016971",
		"default_member_permissions": null,
		"type": 1,
		"name": "pull-model",
		"description": "pulls a model from the ollama model library. Administrator Only.",
		"dm_permission": true,
		"contexts": null,
		"integration_types": [
			0,
			1
		],
		"options": [
			{
				"type": 3,
				"name": "model-to-pull",
				"description": "the name of the model to pull",
				"required": true
			}
		],
		"nsfw": false
	},
	{
		"id": "1411691331495137410",
		"application_id": "1411684728230248448",
		"version": "1411691331495137411",
		"default_member_permissions": null,
		"type": 1,
		"name": "switch-model",
		"description": "switches current model to use.",
		"dm_permission": true,
		"contexts": null,
		"integration_types": [
			0,
			1
		],
		"options": [
			{
				"type": 3,
				"name": "model-to-use",
				"description": "the name of the model to use",
				"required": true
			}
		],
		"nsfw": false
	},
	{
		"id": "1411691332644376618",
		"application_id": "1411684728230248448",
		"version": "1411691332644376619",
		"default_member_permissions": null,
		"type": 1,
		"name": "delete-model",
		"description": "deletes a model from the local list of models. Administrator Only.",
		"dm_permission": true,
		"contexts": null,
		"integration_types": [
			0,
			1
		],
		"options": [
			{
				"type": 3,
				"name": "model-name",
				"description": "the name of the model to delete",
				"required": true
			}
		],
		"nsfw": false
	},
	{
		"id": "1415289674250846239",
		"application_id": "1411684728230248448",
		"version": "1415289674250846240",
		"default_member_permissions": null,
		"type": 1,
		"name": "prompt",
		"description": "Sends a prompt to the bot and creates a thread for discussion.",
		"dm_permission": true,
		"contexts": null,
		"integration_types": [
			0,
			1
		],
		"nsfw": false
	}
]


func _ready():
	UiJsonDisplayAny.display(json, container)
