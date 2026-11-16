extends Node
# Render-only material substitution. Scene geometry and collision data stay original.
var enabled := false
var material: ShaderMaterial
var originals: Dictionary = {}
var tile_overlays: Array = []

func _ready():
 material = ShaderMaterial.new()
 material.shader = load("res://shaders/remaster.gdshader")
 material.set_shader_parameter("ball_art",load("res://assets/remastered/ball.png"))
 material.set_shader_parameter("brick_art",load("res://assets/remastered/brick.png"))
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
  return
 if not (node is Sprite2D or node is AnimatedSprite2D): return
 if not node.get_parent() is Player: return
 # Only level content within the game viewport, never HUD, menu, or water shaders.
 if node.get_viewport() != get_parent().get_node("SubViewportContainer/SubViewport"): return
 if node.material != null and node.material != material: return
 originals[node.get_instance_id()] = weakref(node)
 node.material = material

func set_enabled(value: bool):
 enabled = value
 if enabled:
  _walk(get_parent().get_node("SubViewportContainer/SubViewport"))
 else:
  for reference in originals.values():
   var node = reference.get_ref()
   if is_instance_valid(node) and node.material == material: node.material = null
  originals.clear()
  for reference in tile_overlays:
   var overlay = reference.get_ref()
   if is_instance_valid(overlay):
    overlay.get_parent().self_modulate.a = 1.0
    overlay.free()
  tile_overlays.clear()

func _walk(node: Node):
 _apply_node(node)
 for child in node.get_children(): _walk(child)
