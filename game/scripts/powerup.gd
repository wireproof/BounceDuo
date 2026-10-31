@tool
class_name PowerupBlock
extends StaticBody2D

enum PowerupType{
	Speed, 
	Jump, 
	Flip, 
}

@export var powerup: PowerupType:
	set(value):
		powerup = value
		update_sprite(powerup)


func _ready():
	pass

func update_sprite(_powerup: PowerupType):
	match _powerup:
		PowerupType.Speed:
			$AnimatedSprite2D.play("speed")
		PowerupType.Jump:
			$AnimatedSprite2D.play("jump")
		PowerupType.Flip:
			$AnimatedSprite2D.play("flip")
