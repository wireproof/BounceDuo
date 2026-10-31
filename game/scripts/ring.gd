@tool
extends Node2D

@export var is_wide: bool:
	set(value):
		is_wide = value
		$WideSprites.visible = is_wide
		$Sprites.visible = !is_wide

		$StaticBody2D.process_mode = Node.PROCESS_MODE_DISABLED if is_wide else Node.PROCESS_MODE_INHERIT

var collected: = false

func collect():
	if Engine.is_editor_hint() or collected:
		return

	collected = true
	update_sprites()
	EventBus.collected_ring.emit()

func update_sprites():
	$AnimationPlayer.play("ring_off")

func _on_area_2d_body_entered(body):
	if body is Player:
		collect()

func _on_player_detector_body_entered(body):
	if body is Player and not is_wide:
		if not body.is_big:
			$StaticBody2D.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			$StaticBody2D.process_mode = Node.PROCESS_MODE_INHERIT
