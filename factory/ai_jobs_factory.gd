class_name AiJobFactory extends Node

enum WorkStatus {
	INVALID,
	IN_PROGRESS,
	SUCCESS,
	FAILED
}

class ConsumerRequest:
	var status:WorkStatus
	var time_added:int
	var work:FactoryJob
	var on_done:Callable
	func _init(job:FactoryJob, on_done_cb:Callable):
		status = WorkStatus.IN_PROGRESS
		time_added = Time.get_ticks_msec()
		work = job
		on_done = on_done_cb

var workers:Dictionary[String,Array] = {}

var works_in_progress:Dictionary[String, ConsumerRequest] = {}
var works_todo:Array[ConsumerRequest] = []

func try_dispatch_works():
	print_debug("Factory : Dispatching works")
	var works_dispatched:Array[int] = []
	var n_works_todo:int = len(works_todo)

	print_debug("Factory : %d works to dispatch" % n_works_todo)
	for request_index in range(0, n_works_todo):
		var work_to_do:ConsumerRequest = works_todo[request_index]
		if work_to_do == null:
			print_debug("[BUG] The first consumer request in the list was null !?")
			works_dispatched.append(request_index)
			continue

		var work_type:String = get_job_type(work_to_do.work)
		var specialists:Array = get_workers_for(work_type)
		for specialist in specialists:
			if specialist_handle_request(specialist, work_to_do):
				print_debug("Factory : Dispatched to specialist !")
				works_dispatched.append(request_index)
				continue

	works_dispatched.reverse()
	for index_to_remove in works_dispatched:
		works_todo.remove_at(index_to_remove)

func get_job_type(job:FactoryJob) -> String:
	return job.get_script().get_global_name()

func get_workers_for(job_type:String) -> Array:
	if !workers.has(job_type):
		return []
	return workers[job_type]

func get_consumer_request_related_to(job_result:FactoryJobResponse) -> ConsumerRequest:
	return works_in_progress.get(job_result.id, null)

func worker_finished_a_job(job_result:FactoryJobResponse):
	var work_in_progress := get_consumer_request_related_to(job_result)
	if work_in_progress == null:
		print_debug("[BUG] We're getting the response of a job we were not expecting")
		return

	work_in_progress.on_done.call(job_result)
	if job_result is FactoryJobDone:
		works_in_progress.erase(work_in_progress.work.id)
		try_dispatch_works()

func specialist_handle_request(specialist:FactoryWorker, consumer_request:ConsumerRequest) -> bool:
	var job:FactoryJob = consumer_request.work
	var job_accepted := specialist.receive_job(job)
	if job_accepted:
		works_in_progress[job.id] = consumer_request
	return job_accepted

func request(job:FactoryJob, callback:Callable):
	var work_to_do := ConsumerRequest.new(job, callback)
	works_todo.append(work_to_do)
	try_dispatch_works()

func add_worker_for(worker:FactoryWorker, work_type:String):
	if !workers.has(work_type):
		workers[work_type] = []

	var work_type_workers:Array = get_workers_for(work_type)
	if work_type_workers.has(worker):
		printerr("[BUG] This worker is already register for works of type %s" % work_type)
		return

	worker.job_done.connect(worker_finished_a_job)
	work_type_workers.append(worker)

func remove_worker_for(worker:FactoryWorker, work_type:String):
	if worker == null:
		printerr("[BUG] remove_worker_for called with worker set to null !")
		return

	if !workers.has(work_type):
		printerr("[BUG] No worker registered for works of type %s" % work_type)
		return

	worker.job_done.disconnect(worker_finished_a_job)
	var work_type_workers:Array = get_workers_for(work_type)
	work_type_workers.erase(worker)


func register_worker(worker:FactoryWorker, handled_jobs:PackedStringArray):
	print_debug("Registered a worker !")
	for handled_job in handled_jobs:
		add_worker_for(worker, handled_job)
	try_dispatch_works()

func forget_worker(worker:FactoryWorker, handled_jobs:PackedStringArray):
	for handled_job in handled_jobs:
		remove_worker_for(worker, handled_job)
