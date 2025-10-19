extends Control

@export var factory:AiJobFactory

func get_job_type(response:FactoryJobResponse) -> String:
	return ClassHelpers.get_class_of(response)

func ai_job_done(result:FactoryJobResponse):
	var result_type := get_job_type(result)
	print_debug(result_type)
	match result_type:
		"AiChatResponse":
			var chat_result := result as AiChatResponse
			print_debug(chat_result.response)
			print_debug(chat_result.id)
		"FactoryJobDone":
			var factory_job_done := result as FactoryJobDone
			print_debug(factory_job_done.success)

func _ready():
	factory.request(
		AiChatRequest.new("FEZFJIOPB", "gemma3:1b", "How to use Ryu in Tekken Tournament ?"),
		ai_job_done)
	factory.request(
		AiChatRequest.new("FFBJIOP238", "gemma3:1b", "How to use Sonic in World of Warcraft ?"),
		ai_job_done)
	factory.request(
		AiChatRequest.new("578457230", "gemma3:1b", "Create a Street Fighter game in C# and Unity"),
		ai_job_done)
	
