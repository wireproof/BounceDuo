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
var upscale_enabled := false
var graphics_mode := 2
var remaster: Node
var status_panel: PanelContainer
var status_label: Label
var ability_meter: ProgressBar
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
		upscale_enabled = false # Retire blurry filtering, including previously saved Smooth.
		fill_enabled = bool(prefs.get_value("graphics","fill",true))
	remaster = Node.new()
	remaster.set_script(load("res://scripts/remaster_controller.gd"))
	manager.add_child.call_deferred(remaster)
	graphics_mode = int(prefs.get_value("graphics","preview_mode",2))
	fit_button = Button.new()
	fit_button.pressed.connect(toggle_fill)
	add_child(fit_button)
	graphics_button = Button.new()
	graphics_button.pressed.connect(toggle_graphics)
	add_child(graphics_button)
	call_deferred("apply_graphics")
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
	status_panel = PanelContainer.new()
	status_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.025,0.045,0.07,0.45)
	background.set_corner_radius_all(14)
	status_panel.add_theme_stylebox_override("panel",background)
	add_child(status_panel)
	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_panel.add_child(status_label)
	ability_meter = ProgressBar.new()
	ability_meter.show_percentage = false
	ability_meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ability_meter)
	for button in [pause_button,menu_button,fit_button,graphics_button]:
		button.add_theme_stylebox_override("normal",background.duplicate())
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
	upscale_enabled = false
	manager.get_node("SubViewportContainer").material = null
	graphics_button.text = "Remaster" if graphics_mode == 2 else "Original"
	if is_instance_valid(remaster) and remaster.is_inside_tree(): remaster.set_enabled(graphics_mode == 2)
	if is_instance_valid(menu_button): _relayout()

func toggle_graphics():
	graphics_mode = 0 if graphics_mode == 2 else 2
	apply_graphics()
	var prefs := ConfigFile.new()
	prefs.load("user://graphics.cfg")
	prefs.set_value("graphics","preview_mode",graphics_mode)
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
	if is_instance_valid(status_label):
		status_label.text = ("Lives %d   Rings %d   Score %d" % [manager.hud_controller.life_nodes.size(),manager.ring_count,manager.score]) if get_tree().paused else ("Lives %d   Rings %d" % [manager.hud_controller.life_nodes.size(),manager.ring_count])
		var bar = manager.get_node("LevelUi/fullrect/window/gamesize/Panel/MarginContainer/HBoxContainer/AbilityBar")
		var timer: Timer = bar.timer
		ability_meter.visible = status_panel.visible and is_instance_valid(timer) and not timer.is_stopped()
		if ability_meter.visible: ability_meter.value = 100.0 * timer.time_left / maxf(timer.wait_time,0.01)
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
	var button_size := unit * (0.19 if portrait else 0.13)
	var toolbar_h := unit * 0.095
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
	var resolution := 4 if graphics_mode == 2 else 1
	container.size = Vector2(logical_w,logical_h)*resolution
	container.scale = (Vector2(size.x/logical_w,size.y/logical_h) if immersive else Vector2.ONE*factor)/resolution
	var viewport: SubViewport = manager.get_node("SubViewportContainer/SubViewport")
	viewport.size = Vector2i(int(logical_w),int(logical_h))*resolution
	viewport.size_2d_override = Vector2i(int(logical_w),int(logical_h))
	viewport.size_2d_override_stretch = true
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
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
	hud.visible = game_visible and not immersive
	status_panel.visible = game_visible and immersive
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
	var paused := get_tree().paused
	pause_button.visible = game_visible
	pause_button.text = "Resume" if paused else "II"
	menu_button.visible = game_visible and paused
	graphics_button.visible = game_visible and paused
	fit_button.visible = game_visible and paused and not portrait
	fit_button.text = "Fill" if fill_enabled else "Fit"
	for button in [pause_button,menu_button,fit_button,graphics_button]:
		button.add_theme_font_size_override("font_size",int(toolbar_h*0.35))
		button.size = Vector2(toolbar_h*2.2,toolbar_h)
	pause_button.size.x = toolbar_h*1.6 if paused else toolbar_h*0.8
	pause_button.position = area.position
	menu_button.position = area.get_center()-Vector2(menu_button.size.x/2,toolbar_h*1.8)
	graphics_button.position = menu_button.position+Vector2(0,toolbar_h+gap)
	fit_button.position = graphics_button.position+Vector2(0,toolbar_h+gap)
	status_label.add_theme_font_size_override("font_size",int(toolbar_h*0.28))
	status_panel.size = Vector2(toolbar_h*(5.5 if paused else 3.4),toolbar_h*0.65)
	status_panel.position = Vector2(area.end.x-status_panel.size.x,area.position.y)
	ability_meter.position = status_panel.position+Vector2(0,status_panel.size.y+4)
	ability_meter.size = Vector2(status_panel.size.x,toolbar_h*0.08)
