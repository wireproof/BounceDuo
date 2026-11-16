extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,900)
 root.content_scale_size=Vector2i(1280,900)
 root.content_scale_mode=Window.CONTENT_SCALE_MODE_VIEWPORT
 var game=load("res://scenes/level_manager.tscn").instantiate()
 root.add_child(game)
 await process_frame
 await process_frame
 game.start_game()
 var ui
 for n in game.get_children():
  if n.has_method("toggle_graphics"):ui=n
 ui.graphics_mode=2
 ui.apply_graphics()
 await create_timer(.2).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../level1.png")
 # Render exact atlas regions with production material for asset review.
 var gallery=CanvasLayer.new()
 gallery.layer=100
 root.add_child(gallery)
 var bg=ColorRect.new();bg.color=Color(.06,.12,.18);bg.size=Vector2(1280,900);gallery.add_child(bg)
 var regions=[["Ring wide",128,60],["Ring",140,60],["Used ring",164,60],["Spike",128,36],["Moving hazard",140,36],["Gate",152,36],["Bubble",164,36],["Checkpoint",128,48],["Active",164,48],["Inflator",152,48],["Deflator",164,12],["Speed",140,12],["Jump",152,24],["Gravity",164,24],["Burst",128,12]]
 for i in regions.size():
  var item=regions[i];var tex=AtlasTexture.new();tex.atlas=load("res://assets/Mobile - Bounce - General Sprites.png");tex.region=Rect2(item[1],item[2],12,12)
  var sprite=Sprite2D.new();sprite.texture=tex;sprite.material=ui.remaster.material;sprite.scale=Vector2.ONE*11;sprite.position=Vector2(110+(i%5)*250,130+(i/5)*250);gallery.add_child(sprite)
  var label=Label.new();label.text=item[0];label.position=sprite.position+Vector2(-80,80);label.add_theme_font_size_override("font_size",22);gallery.add_child(label)
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../gallery.png")
 gallery.queue_free()
 await process_frame
 for level in range(11):
  game.play_level(level)
  await create_timer(.08).timeout
  ui.apply_graphics()
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://../level-%02d.png" % (level+1))
 game.end_game()
 await create_timer(.1).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../menu.png")
 print("PASS: rendered all 11 levels and full object atlas gallery")
 quit()
