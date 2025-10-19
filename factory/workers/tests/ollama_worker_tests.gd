extends Control

@export var ollama_worker:OllamaWorker

var chat_jobs:Array[AiChatRequest] = [
	AiChatRequest.new("A15697845169", "gemma3:1b", "In Unity, How to spawn a fish in C# ?"),
	AiChatRequest.new("F16587854689", "gemma3:1b", "I'd like to make a MMORPG like Phantasy Star Online using Unity. What videos would you recommend ?"),
	AiChatRequest.new("B18978949789", "gemma3:1b", "Can a hamster use Thunder Shock and Wild Charge ?"),
]

func job_done(job_result:FactoryJobResponse):
	print_debug(job_result.id)
	if job_result is AiChatResponse:
		var chat_response := job_result as AiChatResponse
		print_debug(chat_response.response)

	if job_result is FactoryJobDone:
		print_debug("Job done. Success ? %s. Reason : %s" % [str(job_result.success), job_result.reason])
		_fire_next_job()

func _fire_next_job():
	var chat_request:AiChatRequest = chat_jobs.pop_front()
	if chat_request != null:
		print_debug("NEXT JOB ! ID : %s, Prompt : %s" % [chat_request.id, chat_request.user_prompt])
		ollama_worker.receive_job(chat_request)

func _ready():
	ollama_worker.job_done.connect(job_done)
	_fire_next_job()
