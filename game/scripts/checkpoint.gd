extends Area2D

var active: bool = false

func _ready():
	EventBus.checkpoint_set.connect(handle_other_checkpoint_set)


func _on_body_entered(body):
	if active or not body is Player:
		return
	active = true
	$AnimatedSprite2D.play("active")
	$Spawnpoint.init_big = body.is_big
	EventBus.checkpoint_set.emit($Spawnpoint)

func remove_if_active():
	if active:
		queue_free()



func handle_other_checkpoint_set(spawnpoint: Marker2D):
	if not active or spawnpoint == $Spawnpoint:
		return
	queue_free()
