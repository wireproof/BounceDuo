extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var game = load("res://scenes/level_manager.tscn").instantiate()
 root.add_child(game)
 await process_frame
 await process_frame
 var layout
 for child in game.get_children():
  if child.has_method("toggle_graphics"): layout = child
 for level in range(11):
  game.play_level(level)
  await process_frame
  var tilemap = game.current_level.get_node("TileMap")
  var tileset = tilemap.tile_set
  var cells = tilemap.get_used_cells(0)
  var collision = game.ball.get_node("CollisionShape2D").shape
  layout.graphics_mode = 2
  layout.apply_graphics()
  await process_frame
  assert(tilemap.has_node("RemasterTiles"))
  assert(tilemap.tile_set == tileset and tilemap.get_used_cells(0) == cells)
  assert(game.ball.get_node("CollisionShape2D").shape == collision)
  layout.graphics_mode = 0
  layout.apply_graphics()
  assert(not tilemap.has_node("RemasterTiles"))
  assert(tilemap.self_modulate.a == 1.0)
  assert(game.ball.get_node("AnimatedSprite2D").material == null)
 print("PASS: 11 levels, remaster on/off restores classic visuals, original tile and ball collisions retained")
 game.queue_free()
 await process_frame
 quit()
