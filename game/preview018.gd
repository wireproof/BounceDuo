extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var game = load("res://scenes/level_manager.tscn").instantiate()
 root.add_child(game)
 await process_frame
 await process_frame
 game.start_game()
 var ui
 for child in game.get_children():
  if child.has_method("toggle_fill"): ui = child
 game.ball.process_mode = Node.PROCESS_MODE_DISABLED
 for dimensions in [Vector2i(1280,900),Vector2i(1194,834),Vector2i(440,900)]:
  root.size = dimensions
  root.content_scale_size = dimensions
  root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
  ui.fill_enabled = true
  ui.set_touch_controls(true)
  for mode in [2,0]:
   ui.graphics_mode = mode
   ui.apply_graphics()
   await create_timer(0.15).timeout
   assert(not ui.menu_button.visible and not ui.fit_button.visible and not ui.graphics_button.visible)
   assert(game.get_node("SubViewportContainer").material == null)
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://../preview-%dx%d-mode%d.png" % [dimensions.x,dimensions.y,mode])
  ui.toggle_pause()
  assert(ui.menu_button.visible and ui.graphics_button.visible)
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://../paused-%dx%d.png" % [dimensions.x,dimensions.y])
  ui.toggle_graphics()
  assert(ui.graphics_mode == 2)
  ui.toggle_pause()
  ui.set_touch_controls(false)
  assert(not ui.controls[0].visible)
 print("PASS: remaster/original, quiet HUD, pause controls, controller hide, portrait and landscape")
 quit()
