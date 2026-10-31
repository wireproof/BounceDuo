extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var game = load("res://scenes/level_manager.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.start_game()
	await create_timer(0.2).timeout
	var start_x = game.ball.position.x
	Input.action_press("move_right")
	await create_timer(0.3).timeout
	Input.action_release("move_right")
	assert(game.ball.position.x > start_x, "right input moves ball")
	var duo
	for child in game.get_children():
		if child.has_method("toggle_pause"): duo=child
	duo.toggle_pause()
	assert(paused)
	duo.toggle_pause()
	assert(not paused)
	for i in range(11):
		game.play_level(i)
		await process_frame
		assert(is_instance_valid(game.ball))
		assert(game.ring_count > 0)
		print("LEVEL ", i+1, " OK")
	print("PASS: movement, pause/resume and all 11 levels instantiate")
	quit()
