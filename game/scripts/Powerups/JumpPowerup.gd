extends Powerup

@export var jump_multiplier: float

func apply_effects():
	player.jump_powerup_multiplier = jump_multiplier

func remove_effects():
	player.jump_powerup_multiplier = 1.0
