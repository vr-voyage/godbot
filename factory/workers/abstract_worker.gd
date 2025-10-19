@abstract class_name FactoryWorker extends Node

signal job_done(result)

@abstract func receive_job(job) -> bool
@abstract func handled_jobs_types() -> PackedStringArray

func _ready():
	print_debug("Registering worker")
	get_tree().call_group("Factories", "register_worker", self, handled_jobs_types())

func _exit_tree():
	get_tree().call_group("Factories", "forget_worker", self, handled_jobs_types())
