extends ColorRect

@export var update_steps: int = 10

var timer: Timer
@onready var init_height: int = custom_minimum_size.y


func _unhandled_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_5:
			start(12)


func _ready():
	EventBus.powerup_collected.connect(start)
	EventBus.player_died.connect(_handle_player_died)

	end()
	timer = Helper.create_timer(1.0, end)
	add_child(timer)



func _process(_delta):
	update_bar()

func update_bar():
	if timer.is_stopped() or timer.time_left <= 0:
		return

	custom_minimum_size.y = get_height(timer.time_left)

func get_height(time: float) -> int:
	var step_height: int = init_height / update_steps
	var height: int = remap(time, 0, timer.wait_time, 0, init_height)
	return snapped(height, step_height)

func start(time: float):
	timer.stop()
	timer.wait_time = time
	timer.start()

func end():
	custom_minimum_size.y = 0

func _handle_player_died():
	timer.stop()
	end()
