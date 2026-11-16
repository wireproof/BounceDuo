extends Node
# Render-only material substitution. Scene geometry and collision data stay original.
var enabled := false
var death_elapsed := 0.0
var material: ShaderMaterial
var originals: Dictionary = {}
var tile_overlays: Array = []
var water_material: ShaderMaterial
var hidden_tiles: ShaderMaterial
var saved_materials: Dictionary = {}

func _ready():
 material = ShaderMaterial.new()
 material.shader = load("res://shaders/remaster.gdshader")
 material.set_shader_parameter("ball_art",load("res://assets/remastered/ball.png"))
 material.set_shader_parameter("brick_art",load("res://assets/remastered/brick.png"))
 hidden_tiles = ShaderMaterial.new()
 hidden_tiles.shader = load("res://shaders/remaster_hide_tiles.gdshader")
 water_material = ShaderMaterial.new()
 water_material.shader = load("res://shaders/remaster_water.gdshader")
 get_tree().node_added.connect(_node_added)

func _node_added(node: Node):
 if enabled: call_deferred("_apply_node",node)

func _apply_node(node: Node):
 if not is_instance_valid(node) or not enabled: return
 if node is TileMap:
  if node.has_node("RemasterTiles"): return
  var overlay = Node2D.new()
  overlay.name = "RemasterTiles"
  overlay.set_script(load("res://scripts/remaster_tiles.gd"))
  node.add_child(overlay)
  tile_overlays.append(weakref(overlay))
  saved_materials[node.get_instance_id()] = node.material
  originals[node.get_instance_id()] = weakref(node)
  node.material = hidden_tiles
  return
 if node is Polygon2D and node.get_parent().get_script() == load("res://scripts/water.gd"):
  if not saved_materials.has(node.get_instance_id()): saved_materials[node.get_instance_id()] = node.material
  originals[node.get_instance_id()] = weakref(node)
  node.material = water_material
  return
 if not (node is Sprite2D or node is AnimatedSprite2D): return
 if node is Sprite2D and node.texture is PlaceholderTexture2D: return
 # Only level content within the game viewport, never HUD, menu, or water shaders.
 if node.get_viewport() != get_parent().get_node("SubViewportContainer/SubViewport"): return
 if node.material != null and node.material != material: return
 if not saved_materials.has(node.get_instance_id()): saved_materials[node.get_instance_id()] = node.material
 originals[node.get_instance_id()] = weakref(node)
 node.material = material

func set_enabled(value: bool):
 enabled = value
 if enabled:
  _walk(get_parent().get_node("SubViewportContainer/SubViewport"))
 else:
  for reference in originals.values():
   var node = reference.get_ref()
   if is_instance_valid(node): node.material = saved_materials.get(node.get_instance_id(),null)
  originals.clear()
  saved_materials.clear()
  for reference in tile_overlays:
   var overlay = reference.get_ref()
   if is_instance_valid(overlay):
    overlay.get_parent().self_modulate.a = 1.0
    overlay.free()
  tile_overlays.clear()

func _walk(node: Node):
 _apply_node(node)
 for child in node.get_children(): _walk(child)

func _process(delta):
 if not enabled: return
 var ball = get_parent().ball
 if is_instance_valid(ball):
  death_elapsed = minf(death_elapsed + delta,1.0) if ball.is_dead else 0.0
  material.set_shader_parameter("death_phase",death_elapsed)
