extends Area2D

func _on_body_entered(_body):
	EventBus.bubble_collected.emit()
	queue_free()
