extends Path2D

@export var speed: float = 24

var direction = 1


func _ready():
	pass



func _physics_process(delta):
	if curve == null:
		return
	$PathFollow2D.progress += speed * delta * direction
	if $PathFollow2D.progress >= curve.get_baked_length():
		direction = -1
	elif $PathFollow2D.progress <= 0:
		direction = 1
