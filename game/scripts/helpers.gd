class_name Helper
extends Node

static func create_timer(time: float, callback: Callable) -> Timer:
	assert (time > 0)
	var timer = Timer.new()
	timer.wait_time = time
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(callback)
	return timer
