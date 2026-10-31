extends Area2D



func _on_body_entered(body):
	EventBus.player_died.emit()
