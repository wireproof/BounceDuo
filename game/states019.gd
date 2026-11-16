extends SceneTree
func _initialize():call_deferred("run")
func all_nodes(n:Node)->Array:
 var a=[n]
 for c in n.get_children():a.append_array(all_nodes(c))
 return a
func run():
 root.size=Vector2i(1280,900);root.content_scale_size=root.size;root.content_scale_mode=Window.CONTENT_SCALE_MODE_VIEWPORT
 var game=load("res://scenes/level_manager.tscn").instantiate();root.add_child(game)
 await process_frame;await process_frame
 game.start_game()
 var ui
 for n in game.get_children():
  if n.has_method("toggle_graphics"):ui=n
 ui.graphics_mode=2
 ui.apply_graphics()
 game.ball.process_mode=Node.PROCESS_MODE_DISABLED
 var viewport=game.get_node("SubViewportContainer/SubViewport")
 for n in all_nodes(viewport):
  if n is Camera2D:n.enabled=false
 var cam=Camera2D.new();viewport.add_child(cam);cam.position=Vector2(70,48);cam.make_current()
 game.current_level.hide()
 var stage=Node2D.new();viewport.add_child(stage)
 for pair in [["ring",Vector2(25,40)],["moving_spike",Vector2(40,20)],["spike",Vector2(70,34)],["exit_gate",Vector2(100,30)],["checkpoint",Vector2(10,65)],["inflator",Vector2(30,65)],["deflator",Vector2(48,65)],["powerup",Vector2(66,65)],["bubble",Vector2(88,65)],["water",Vector2(40,80)]]:
  var node=load("res://scenes/"+pair[0]+".tscn").instantiate();node.position=pair[1];stage.add_child(node)
 await process_frame
 ui.apply_graphics()
 await create_timer(.2).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../objects-closed.png")
 for n in stage.get_children():
  if n.has_method("open_gate"):n.open_gate()
  if n.has_method("collect"):n.collect()
 await create_timer(1.1).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../objects-open.png")
 for n in stage.get_children():
  if n.has_method("open_gate"):assert(n.is_open and n.get_node("StaticBody2D/CollisionShape2D").disabled)
 print("PASS: rendered assembled objects, animated water, ring collected state and exit gate opening")
 game.queue_free();await process_frame;quit()
