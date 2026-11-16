extends SceneTree
func _initialize():call_deferred("run")
func nodes(n:Node)->Array:
 var a=[n]
 for child in n.get_children():a.append_array(nodes(child))
 return a
func run():
 var game=load("res://scenes/level_manager.tscn").instantiate();root.add_child(game)
 await process_frame
 await process_frame
 var ui
 for n in game.get_children():
  if n.has_method("toggle_graphics"):ui=n
 var count=0
 for level in range(11):
  ui.graphics_mode=0;ui.apply_graphics()
  game.play_level(level)
  await process_frame
  var snapshots={}
  var visuals={}
  for n in nodes(game.current_level):
   if n is CollisionShape2D:snapshots[n]=[n.shape,n.transform,n.disabled]
   if n is CollisionPolygon2D:snapshots[n]=[n.polygon,n.transform,n.disabled]
   if n is TileMap:
    for layer in n.get_layers_count():
     for cell in n.get_used_cells(layer):
      assert(n.get_cell_atlas_coords(layer,cell).x in [10,11] or not n.tile_set.has_source(n.get_cell_source_id(layer,cell)))
   if n is Sprite2D or n is AnimatedSprite2D or n is Polygon2D or n is TileMap:visuals[n]=n.material
  ui.graphics_mode=2;ui.apply_graphics()
  await process_frame
  for n in snapshots:
   var expected=snapshots[n]
   assert(n.transform==expected[1] and n.disabled==expected[2])
   assert(n.shape==expected[0] if n is CollisionShape2D else n.polygon==expected[0])
   count+=1
  ui.graphics_mode=0;ui.apply_graphics()
  for n in visuals:assert(n.material==visuals[n])
 ui.graphics_mode=2;ui.apply_graphics()
 var ring=game.current_level.find_child("Ring*",true,false)
 if ring and ring.has_method("collect"):
  ring.collect();await process_frame;assert(ring.collected)
 game.ball.die();await process_frame
 assert(game.ball.get_node("AnimatedSprite2D").animation=="dead")
 assert(ui.remaster.material.get_shader_parameter("death_phase")>=0)
 game.ball.revive()
 ui.toggle_pause();assert(ui.graphics_button.visible)
 ui.toggle_graphics();assert(ui.graphics_mode==0)
 ui.toggle_pause();assert(not ui.graphics_button.visible)
 print("PASS: 11 levels; %d collision states unchanged; every material restored; collection/death/pause toggles" % count)
 game.queue_free();await process_frame;quit()
