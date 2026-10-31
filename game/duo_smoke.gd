extends SceneTree
func _initialize():
	call_deferred("run")
func run():
	var game = load("res://scenes/level_manager.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	game.start_game()
	for dim in [Vector2i(900,1280),Vector2i(1280,900),Vector2i(440,900)]:
		root.size=dim
		root.content_scale_size=dim
		root.content_scale_mode=Window.CONTENT_SCALE_MODE_VIEWPORT
		await create_timer(0.5).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../docs/layout-%dx%d.png" % [dim.x,dim.y])
	print("DUO SMOKE COMPLETE")
	quit()
