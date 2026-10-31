extends Powerup

@export var speed_multiplier: float

func apply_effects():
	player.speed_multiplier = speed_multiplier

func remove_effects():
	player.speed_multiplier = 1.0
