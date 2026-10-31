class_name ExitGate
extends Area2D

var is_open: = false
var has_exited: = false

func open_gate():
	if is_open:
		return
	is_open = true
	$AnimationPlayer.play("open_gate")


func _on_body_entered(_body):
	if has_exited or not is_open:
		return
	has_exited = true
	EventBus.exited_level.emit()
