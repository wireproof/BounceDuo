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
	root.size = Vector2i(1194,834)
	await process_frame
	duo.fill_enabled = false
	duo._relayout()
	duo.set_touch_controls(true)
	var touch_scale = game.get_node("SubViewportContainer").scale.x
	var key = InputEventKey.new()
	key.physical_keycode = KEY_RIGHT
	key.pressed = true
	duo._input(key)
	assert(not duo.touch_controls)
	assert(not duo.controls[0].visible)
	assert(game.get_node("SubViewportContainer").scale.x > touch_scale)
	var touch = InputEventScreenTouch.new()
	touch.pressed = true
	duo._input(touch)
	assert(duo.touch_controls and duo.controls[0].visible)
	duo._joy_connection_changed(0, true)
	assert(not duo.touch_controls)
	duo._joy_connection_changed(0, false)
	assert(duo.touch_controls)
	print("PASS: keyboard/controller hide controls, touch restores, game expands")
	for dimensions in [Vector2i(1280,900),Vector2i(1194,834)]:
		root.size = dimensions
		await process_frame
		duo.fill_enabled = true
		duo._relayout()
		await process_frame
		duo._relayout()
		var canvas = game.get_node("SubViewportContainer")
		assert(canvas.position == Vector2.ZERO)
		assert((canvas.size * canvas.scale).distance_to(Vector2(dimensions)) < 1)
	print("PASS: Duo and iPad landscape Fill covers full viewport")
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
	game.queue_free()
	await process_frame
	await process_frame
	quit()
