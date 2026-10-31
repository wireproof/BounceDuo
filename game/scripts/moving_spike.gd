extends CharacterBody2D

@export var speed: float
@export var init_direction: = Vector2(0, -1)


func _ready():
	if init_direction == Vector2.RIGHT or init_direction == Vector2.LEFT:
		var rect: RectangleShape2D = RectangleShape2D.new()
		rect.size.x = 24
		rect.size.y = 20
		$CollisionShape2D.shape = rect
	velocity = init_direction * speed

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)

	if collision:
		flip_velocity()


	$Sprites.global_position = global_position.round() + Vector2(6, 6)

func flip_velocity():
	velocity *= -1
