extends Area2D

func _on_body_entered(_body):
	EventBus.player_died.emit()
