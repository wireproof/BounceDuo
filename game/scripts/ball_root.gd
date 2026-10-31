class_name Player
extends CharacterBody2D

@export_group("Regular Ball Properties")
@export var JUMP_VELOCITY = -220.0
@export var ACCELERATION = 0.3
@export var DECELERATION = 0.3
@export var MAX_SPEED = 130.0
@export var BOUNCE_MIN_VEL = 30.0
@export var BOUNCE_MULT = 0.33
@export var SINK_GRAVITY_MULT = 0.75
@export var MAX_SINK_SPEED = 135.0

@export_group("Big Ball Properties")
@export var BIG_GRAVITY_MULT = 0.7
@export var BIG_JUMP_VELOCITY = -160.0
@export var BIG_FLOAT_SPEED = 200.0
@export var BIG_MAX_FLOAT_SPEED = 75.0
@export var BIG_MAX_FALL_SPEED = 100.0

const MAX_VELOCITY: = 400.0

var is_dead: = false
var is_big: = false
var is_underwater: = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var floor_bounce_mult: = 1.0
var floor_bounce_accel: = 1.0

var speed_multiplier: float = 1.0
var jump_powerup_multiplier: float = 1.0
var flip_powerup_multiplier: int = 1

@onready var powerup_speed = $SpeedPowerup
@onready var powerup_jump = $JumpPowerup
@onready var powerup_flip = $FlipPowerup


func _ready():
	$AnimatedSprite2D.play("default")

func _process(_delta):
	$AnimatedSprite2D.global_position = global_position.round()

func _physics_process(delta):

	if is_big:
		if is_underwater:

			velocity.y -= BIG_FLOAT_SPEED * delta * flip_powerup_multiplier
			velocity.y = clamp(velocity.y, - BIG_MAX_FLOAT_SPEED, BIG_MAX_FLOAT_SPEED)
		else:
			velocity.y += gravity * delta * BIG_GRAVITY_MULT * flip_powerup_multiplier

			if velocity.y > BIG_MAX_FALL_SPEED:
				velocity.y = BIG_MAX_FALL_SPEED
	else:
		if is_underwater:

			velocity.y += gravity * delta * SINK_GRAVITY_MULT * flip_powerup_multiplier
			velocity.y = clamp(velocity.y, - MAX_SINK_SPEED, MAX_SINK_SPEED)
		else:
			velocity.y += gravity * delta * flip_powerup_multiplier


	if Input.is_action_just_released("jump"):
		floor_bounce_mult = 1.0


	if Input.is_action_pressed("jump") and is_on_floor():
		floor_bounce_mult *= floor_bounce_accel
		floor_bounce_mult = clamp(floor_bounce_mult, 1.0, 2.5)
		velocity.y = jump_powerup_multiplier * floor_bounce_mult * flip_powerup_multiplier * (JUMP_VELOCITY if not is_big else BIG_JUMP_VELOCITY)


	var direction = Input.get_axis("move_left", "move_right")

	if direction:
		velocity.x = lerpf(velocity.x, MAX_SPEED * direction * speed_multiplier, ACCELERATION)
	else:
		velocity.x = lerpf(velocity.x, 0.0, DECELERATION)



	if velocity.y < - MAX_VELOCITY:
		velocity.y = - MAX_VELOCITY
	elif velocity.y > MAX_VELOCITY:
		velocity.y = MAX_VELOCITY



	var premove_velocity: Vector2 = velocity
	if move_and_slide():
		var collision: KinematicCollision2D = get_last_slide_collision()

		check_obstacles(collision)

		var dot_product = collision.get_normal().dot(Vector2.UP)
		var is_vertical: bool = dot_product > 0.9 or dot_product < -0.9
		var is_horizontal: bool = dot_product > -0.1 and dot_product < 0.1

		if is_vertical and abs(premove_velocity.y) > BOUNCE_MIN_VEL:
			velocity.y = - premove_velocity.y * BOUNCE_MULT * floor_bounce_mult

		elif is_horizontal and abs(premove_velocity.x) > BOUNCE_MIN_VEL:
			velocity.x = - premove_velocity.x * BOUNCE_MULT * floor_bounce_mult



func move(pos: Vector2):
	global_position = pos

func set_living(value: bool) -> bool:
	if !value and is_dead:
		return false
	is_dead = !value
	$AnimatedSprite2D.play("default" if value else "dead")

	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", !value)
	set_physics_process(value)
	return true

func die() -> bool:
	return set_living(false)

func revive() -> bool:
	return set_living(true)


func check_obstacles(collision: KinematicCollision2D):
	if collision == null:
		return
	var collider = collision.get_collider()
	if collider is Node:
		if collider.is_in_group("Inflator"):
			inflate()
		elif collider.is_in_group("Deflator"):
			deflate()
		elif collider is TileMap:
			var tilemap = collider as TileMap
			check_floor_type(tilemap, collision)
		elif collider is PowerupBlock:
			add_powerup(collider as PowerupBlock)
			print("hit powerup!")


func check_floor_type(tilemap: TileMap, collision: KinematicCollision2D):
	var tile_pos = tilemap.local_to_map(tilemap.to_local(collision.get_position()))
	var tile_data = tilemap.get_cell_tile_data(0, tile_pos)
	if tile_data:
		var bounce = tile_data.get_custom_data_by_layer_id(0)
		if floor_bounce_accel != bounce:
			floor_bounce_accel = bounce if bounce != null else 1.0
			floor_bounce_mult = 1.0
		print("Bounce value: ", bounce)

func set_size(big: bool):
	if is_dead or (big and is_big):
		return

	if big:
		$AnimatedSprite2D.play("big")
		$CollisionShape2D.shape.radius = 8
	else:
		$AnimatedSprite2D.play("default")
		$CollisionShape2D.shape.radius = 5.95

	is_big = big

func inflate():
	set_size(true)

func deflate():
	set_size(false)

func set_underwater(value: bool):
	if is_dead or (is_underwater and value):
		return

	if value:
		print("Now underwater!")
	else:
		print("Now out of water!")

	is_underwater = value

func enter_water():
	set_underwater(true)

func exit_water():
	set_underwater(false)

func add_powerup(powerup_block: PowerupBlock):
	match powerup_block.powerup:
		PowerupBlock.PowerupType.Speed:
			powerup_speed.start_powerup()
		PowerupBlock.PowerupType.Jump:
			powerup_jump.start_powerup()
		PowerupBlock.PowerupType.Flip:
			powerup_flip.start_powerup()
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
