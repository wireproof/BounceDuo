extends Powerup

func apply_effects():
	player.flip_powerup_multiplier = -1
	player.up_direction = Vector2.DOWN

func remove_effects():
	player.flip_powerup_multiplier = 1
	player.up_direction = Vector2.UP
