extends CanvasLayer
# Layout only; the recovered remake owns physics, levels and sounds.
var manager: Node
var controls: Array[TouchScreenButton] = []
var pause_button: Button
var menu_button: Button
var graphics_button: Button
var fit_button: Button
var fill_enabled := true
var upscale_material: ShaderMaterial
var upscale_enabled := true
var last_size := Vector2.ZERO
var last_screen := -1
var touch_controls := true
var last_safe_area := Rect2i()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	manager = get_parent()
	upscale_material = ShaderMaterial.new()
	upscale_material.shader = load("res://shaders/pixel_upscale.gdshader")
	var prefs := ConfigFile.new()
	if prefs.load("user://graphics.cfg") == OK:
		upscale_enabled = bool(prefs.get_value("graphics","upscale",true))
		fill_enabled = bool(prefs.get_value("graphics","fill",true))
	fit_button = Button.new()
	fit_button.pressed.connect(toggle_fill)
	add_child(fit_button)
	graphics_button = Button.new()
	graphics_button.pressed.connect(toggle_graphics)
	add_child(graphics_button)
	apply_graphics()
	for pair in [["move_left", "left"], ["move_right", "right"], ["jump", "jump"]]:
		var button := TouchScreenButton.new()
		button.texture_normal = load("res://assets/buttons/" + pair[1] + ".svg")
		button.action = pair[0]
		button.passby_press = true
		var shape := RectangleShape2D.new()
		shape.size = Vector2(32, 32)
		button.shape = shape
		button.shape_visible = false
		add_child(button)
		controls.append(button)
	pause_button = Button.new()
	pause_button.text = "Pause"
	pause_button.pressed.connect(toggle_pause)
	add_child(pause_button)
	menu_button = Button.new()
	menu_button.text = "Menu"
	menu_button.pressed.connect(return_menu)
	add_child(menu_button)
	manager.get_node("LevelUi/fullrect/window/MarginContainer").hide()
	manager.get_node("LevelUi/fullrect/window").custom_minimum_size.y = 128
	manager.get_node("SubViewportContainer/SubViewport").size = Vector2i(168,128)
	for action in ["move_left", "move_right", "jump"]:
		var event := InputEventJoypadButton.new()
		event.button_index = JOY_BUTTON_DPAD_LEFT if action == "move_left" else JOY_BUTTON_DPAD_RIGHT if action == "move_right" else JOY_BUTTON_A
		InputMap.action_add_event(action, event)
	Input.joy_connection_changed.connect(_joy_connection_changed)
	touch_controls = Input.get_connected_joypads().is_empty()
	_relayout()

func _joy_connection_changed(_device: int, connected: bool):
	if connected:
		set_touch_controls(false)
	elif Input.get_connected_joypads().is_empty():
		set_touch_controls(true)

func set_touch_controls(enabled: bool):
	if touch_controls == enabled: return
	touch_controls = enabled
	_relayout()

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		set_touch_controls(true)
	elif event is InputEventKey and event.pressed and not event.echo:
		set_touch_controls(false)
	elif event is InputEventJoypadButton and event.pressed:
		set_touch_controls(false)
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.25:
		set_touch_controls(false)

func apply_graphics():
	manager.get_node("SubViewportContainer").material = upscale_material if upscale_enabled else null
	graphics_button.text = "Smooth" if upscale_enabled else "Original"

func toggle_graphics():
	upscale_enabled = not upscale_enabled
	apply_graphics()
	var prefs := ConfigFile.new()
	prefs.load("user://graphics.cfg")
	prefs.set_value("graphics","upscale",upscale_enabled)
	prefs.save("user://graphics.cfg")

func toggle_fill():
	fill_enabled = not fill_enabled
	_relayout()
	var prefs := ConfigFile.new()
	prefs.load("user://graphics.cfg")
	prefs.set_value("graphics","fill",fill_enabled)
	prefs.save("user://graphics.cfg")

func clear_input():
	for action in ["move_left", "move_right", "jump"]:
		Input.action_release(action)

func toggle_pause():
	clear_input()
	get_tree().paused = not get_tree().paused
	pause_button.text = "Resume" if get_tree().paused else "Pause"
	_relayout()

func return_menu():
	clear_input()
	get_tree().paused = false
	pause_button.text = "Pause"
	manager.end_game()

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(manager):
		clear_input()
		if manager.current_screen == manager.Screens.HUD:
			get_tree().paused = true
			pause_button.text = "Resume"
			_relayout()

func _process(_delta):
	if last_size != get_viewport().get_visible_rect().size or last_screen != manager.current_screen or last_safe_area != DisplayServer.get_display_safe_area():
		_relayout()

func _relayout():
	var size := get_viewport().get_visible_rect().size
	if size.x < 1 or size.y < 1: return
	last_safe_area = DisplayServer.get_display_safe_area()
	last_size = size
	last_screen = manager.current_screen
	var game_visible: bool = last_screen == manager.Screens.HUD
	var inset := 8.0
	var area := Rect2(Vector2(inset,inset),size-Vector2(inset*2,inset*2))
	if OS.has_feature("ios"):
		var safe := Rect2(DisplayServer.get_display_safe_area())
		var window := Vector2(DisplayServer.window_get_size())
		if window.x > 0 and window.y > 0:
			safe.position *= size/window
			safe.size *= size/window
			area = area.intersection(safe)
	# Size controls in proportion to the visible screen, not a fixed pixel cap.
	var portrait := area.size.y >= area.size.x
	var unit := minf(area.size.x, area.size.y)
	var gap := unit * 0.025
	var button_size := unit * (0.23 if portrait else 0.19)
	var toolbar_h := minf(unit * 0.075,60.0)
	var play_area := area
	play_area.position.y += toolbar_h + gap
	play_area.size.y -= toolbar_h + gap
	if touch_controls and portrait:
		play_area.size.y -= button_size + gap * 2
	elif touch_controls:
		play_area.position.x += button_size * 2 + gap * 2
		play_area.size.x -= button_size * 3 + gap * 4
	var immersive := fill_enabled and not portrait
	var logical_w := 168.0
	var factor := play_area.size.x / logical_w
	# The original camera uses 96-pixel vertical bands; preserve that view.
	var logical_h := 128.0
	factor = minf(factor, play_area.size.y / logical_h)
	var origin := play_area.position + Vector2((play_area.size.x-logical_w*factor)/2,0)
	if immersive:
		logical_h = 96.0
		logical_w = roundf(logical_h * size.x / size.y)
		factor = size.y / logical_h
		origin = Vector2.ZERO
	var container: Control = manager.get_node("SubViewportContainer")
	manager.get_node("SubViewportContainer/SubViewport").size = Vector2i(int(logical_w),int(logical_h))
	container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	container.custom_minimum_size = Vector2.ZERO
	container.position = origin
	container.size = Vector2(logical_w,logical_h)
	container.scale = Vector2(size.x/logical_w,size.y/logical_h) if immersive else Vector2.ONE*factor
	container.visible = game_visible
	var hud: Control = manager.get_node("LevelUi/fullrect")
	hud.set_anchors_preset(Control.PRESET_TOP_LEFT)
	hud.position = origin
	hud.size = Vector2(168,logical_h)
	hud.scale = Vector2.ONE*factor
	manager.get_node("LevelUi/fullrect/window").custom_minimum_size.y = logical_h
	manager.get_node("LevelUi/fullrect/window/gamesize").custom_minimum_size.y = logical_h
	manager.get_node("LevelUi/fullrect/window/gamesize").size.y = logical_h
	manager.get_node("LevelUi/fullrect/window").size.y = logical_h
	hud.size = Vector2(168,logical_h)
	# Keep the existing score, lives, rings and ability meter as a compact overlay.
	if immersive:
		var hud_factor := minf(area.size.x * 0.36 / 168.0, 2.8)
		hud.scale = Vector2.ONE * hud_factor
		hud.position = Vector2(area.get_center().x - 84.0 * hud_factor,area.end.y - 32.0 * hud_factor)
		for part in ["fullrect/window/gamesize", "fullrect/window", "fullrect"]:
			var control: Control = manager.get_node("LevelUi/" + part)
			control.custom_minimum_size.y = 32
			control.size = Vector2(168,32)
	for name in ["MainMenu","TransitionScreen"]:
		var panel: Control = manager.get_node(name)
		var f := minf(area.size.x/168.0,area.size.y/224.0)
		panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
		panel.size = Vector2(168,224)
		panel.scale = Vector2.ONE*f
		panel.position = area.position + (area.size-Vector2(168,224)*f)/2
	var controls_y := minf(origin.y+logical_h*factor+gap*2,area.end.y-button_size)
	for i in range(3):
		controls[i].modulate.a = 0.55 if immersive else 1.0
		controls[i].visible = touch_controls and game_visible and not get_tree().paused
		controls[i].scale = Vector2.ONE * button_size/32.0
		var x := area.position.x + i*(button_size+gap)
		if i == 2: x = area.end.x-button_size
		controls[i].position = Vector2(x,controls_y if portrait else area.end.y-button_size)
	pause_button.visible = game_visible
	menu_button.visible = game_visible
	graphics_button.visible = game_visible
	fit_button.visible = game_visible and not portrait
	fit_button.text = "Fill" if fill_enabled else "Fit"
	for button in [pause_button,menu_button,graphics_button,fit_button]:
		button.add_theme_font_size_override("font_size",int(toolbar_h*0.46))
		button.size = Vector2(toolbar_h*2.3,toolbar_h)
	pause_button.position = Vector2(area.position.x,area.position.y)
	menu_button.position = Vector2(area.end.x-menu_button.size.x,area.position.y)
	graphics_button.position = Vector2(area.get_center().x-graphics_button.size.x-gap/2,area.position.y)
	fit_button.position = Vector2(area.get_center().x+gap/2,area.position.y)
	if portrait: graphics_button.position.x = area.get_center().x-graphics_button.size.x/2
