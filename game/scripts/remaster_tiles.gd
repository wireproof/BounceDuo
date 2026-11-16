extends Node2D
var tiles: TileMap
var art: Texture2D
func _ready():
 tiles = get_parent()
 art = load("res://assets/remastered/brick.png")
 texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
 var shader_material = ShaderMaterial.new()
 shader_material.shader = load("res://shaders/remaster_tiles.gdshader")
 material = shader_material
 queue_redraw()
func _draw():
 if not is_instance_valid(tiles) or art == null: return
 for layer in range(tiles.get_layers_count()):
  for cell in tiles.get_used_cells(layer):
   var atlas = tiles.get_cell_atlas_coords(layer,cell)
   if atlas.x != 10 and atlas.x != 11: continue
   var center = tiles.map_to_local(cell)
   var alt = tiles.get_cell_alternative_tile(layer,cell)
   var vertices = PackedVector2Array([Vector2(-6,6),Vector2(6,-6),Vector2(6,6)]) if atlas.x == 10 else PackedVector2Array([Vector2(-6,-6),Vector2(6,-6),Vector2(6,6),Vector2(-6,6)])
   var uv = PackedVector2Array([Vector2(0,1),Vector2(1,0),Vector2(1,1)]) if atlas.x == 10 else PackedVector2Array([Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,1)])
   for i in range(vertices.size()):
    var point = vertices[i]
    if alt & 16384: point = Vector2(point.y,point.x)
    if alt & 4096: point.x = -point.x
    if alt & 8192: point.y = -point.y
    vertices[i] = center + point
   draw_polygon(vertices,PackedColorArray([Color(0.12,0.55,1.0) if atlas.y == 2 else Color.WHITE]),uv,art)
