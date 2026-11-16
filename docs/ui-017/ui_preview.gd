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
 game.score = 9400
 for dimensions in [Vector2i(1280,900),Vector2i(2732,1920),Vector2i(1194,834)]:
  root.size = dimensions
  root.content_scale_size = dimensions
  root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
  ui.fill_enabled = true
  ui.set_touch_controls(true)
  ui._relayout()
  await create_timer(0.15).timeout
  ui._relayout()
  await RenderingServer.frame_post_draw
  assert(ui.pause_button.size.y / dimensions.y > 0.08)
  assert(ui.controls[0].scale.x * 32 / dimensions.y < 0.15)
  assert(ui.status_panel.visible)
  assert(not game.get_node("LevelUi/fullrect").visible)
  assert(not ui.graphics_button.visible)
  assert(game.get_node("SubViewportContainer").material == null)
  assert(ui.status_label.text.contains("9400"))
  root.get_texture().get_image().save_png("res://../docs/ui-%dx%d.png" % [dimensions.x,dimensions.y])
 var bar = game.get_node("LevelUi/fullrect/window/gamesize/Panel/MarginContainer/HBoxContainer/AbilityBar")
 bar.start(12)
 ui._process(0)
 assert(ui.ability_meter.visible and ui.ability_meter.value > 90)
 bar.end()
 bar.timer.stop()
 ui._process(0)
 assert(not ui.ability_meter.visible)
 ui.set_touch_controls(false)
 assert(not ui.controls[0].visible)
 print("PASS: responsive UI at Duo/iPad and high-density dimensions; crisp rendering; HUD values; auto-hide")
 quit()
