class_name Powerup
extends Node

@onready var player: Player = owner

@export var duration: float

var is_active: bool = false
var duration_timer: Timer

func _ready():
	duration_timer = Helper.create_timer(duration, end_powerup)
	add_child(duration_timer)


func start_powerup():
	if is_active:
		duration_timer.stop()
	is_active = true
	duration_timer.start()
	apply_effects()
	EventBus.powerup_collected.emit(duration)

func end_powerup():
	if not is_active:
		return
	is_active = false
	remove_effects()


func apply_effects():
	pass

func remove_effects():
	pass
