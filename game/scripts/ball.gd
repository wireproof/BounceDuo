extends RigidBody2D


@export var ground_raycast: RayCast2D

var bounced_in_prev_frame = false
var velocity: Vector2 = Vector2.ZERO


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	assert (ground_raycast != null)

func _integrate_forces(state):
	pass


func is_grounded() -> bool:
	ground_raycast.force_raycast_update()
	return ground_raycast.is_colliding()
