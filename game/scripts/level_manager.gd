extends Node

@export var respawn_time: float = 1.0
@export var hud_controller: HUDController

@export var ring_score: = 50
@export var checkpoint_score: = 20
@export var bubble_score: = 100


@export var levels: Array[PackedScene]

enum Screens{
	HUD, 
	MainMenu, 
	Transition
}
var current_screen: Screens = Screens.MainMenu

var ball: Node2D
var camera: PlayerCamera
var exit_gate: ExitGate
var spawnpoints: Array[Node]
var active_spawnpoint: Marker2D
var current_level: Node
var current_level_index: int = 0

var life_count: = 2
var ring_count: int
var score: = 0

@onready var subviewport: SubViewport = $SubViewportContainer / SubViewport
@onready var respawn_timer: Timer = Timer.new()
@onready var transition_screen: TransitionScreen = $TransitionScreen
var ball_scene = preload("res://scenes/ball.tscn")


func _ready():
	var duo = CanvasLayer.new()
	duo.set_script(load("res://scripts/duo_layout.gd"))
	add_child(duo)

	SaveManager.load_game()


	EventBus.exited_level.connect(handle_level_complete)
	EventBus.bubble_collected.connect(handle_bubble_collected)
	EventBus.checkpoint_set.connect(set_checkpoint)
	EventBus.player_died.connect(handle_player_death)
	EventBus.collected_ring.connect(handle_collect_ring)
	EventBus.play_level.connect(_on_level_menu_play_level)


	respawn_timer.timeout.connect(respawn_player)
	respawn_timer.autostart = false
	respawn_timer.one_shot = true
	add_child(respawn_timer)

func _unhandled_input(event):
	if current_level == null:
		return
	if event is InputEventKey:
		if event.keycode == KEY_9:

			if EventBus.player_died.is_connected(handle_player_death):
				$AudioManager.play_sfx(AudioManager.SFX.Collect)
				EventBus.player_died.disconnect(handle_player_death)
		elif event.keycode == KEY_0:

			EventBus.exited_level.emit()
		elif event.keycode == KEY_ESCAPE:

			end_game()

func _on_level_menu_play_level(number: int):
	if levels.size() < number:
		return
	current_level_index = number - 1
	start_game()

func load_latest_level():
	current_level_index = SaveManager.save_data["level_reached"]
	start_game()

func start_game():

	score = 0
	life_count = 2

	transition_screen.reset()


	play_level(current_level_index)


	hud_controller.set_lives(life_count)


func end_game():
	call_deferred("unload_current_level")

	SaveManager.load_game()

	score = 0
	hud_controller.update_score(score)

	transition_screen.reset()

	switch_ui(Screens.MainMenu)

func set_screen_visible(screen: Screens, visible: bool):
	match screen:
		Screens.HUD:
			$LevelUi.visible = visible
		Screens.MainMenu:
			$MainMenu.switch_screen(MainMenu.Screens.MainMenu)
			$MainMenu.visible = visible
		Screens.Transition:
			$TransitionScreen.visible = visible

func switch_ui(dest: Screens):
	if dest == current_screen:
		return

	set_screen_visible(current_screen, false)
	set_screen_visible(dest, true)

	current_screen = dest

func get_spawnpoints():
	spawnpoints = get_tree().get_nodes_in_group("spawnpoints")
	assert (spawnpoints != null && spawnpoints.size() > 0)

	for spawnpoint in spawnpoints:
		if spawnpoint is Marker2D && spawnpoint.init_active:
			active_spawnpoint = spawnpoint as Marker2D
			break
	assert (active_spawnpoint != null)


func get_exit_gate():
	var exit_gates = get_tree().get_nodes_in_group("ExitGate")
	if exit_gates.is_empty():
		push_error("No exit gate inside level.")
	elif exit_gates.size() > 1:
		push_error("Cannot have multiple exit gates in the same level.")
	elif not exit_gates[0] is ExitGate:
		push_error("Exit gate is not of correct type.")

	exit_gate = exit_gates[0] as ExitGate

func handle_level_complete():

	call_deferred("unload_current_level")


	$AudioManager.play_sfx(AudioManager.SFX.Secondary)


	score += 500
	score *= 10


	update_save()

	transition_screen.level = current_level_index + 1
	transition_screen.score = score
	if current_level_index + 1 >= levels.size():
		transition_screen.set_label("Congrats!")
	else:
		transition_screen.update_label()
	switch_ui(Screens.Transition)

func play_next_level():
	if current_level_index + 1 >= levels.size():
		print_debug("Reached end of levels")
		end_game()
		return

	score /= 10

	hud_controller.update_score(score)

	call_deferred("play_level", current_level_index + 1)

func unload_current_level():
	if current_level != null:
		current_level.free()

func play_level(level_num: int):
	unload_current_level()

	current_level_index = level_num
	current_level = levels[current_level_index].instantiate()
	subviewport.add_child(current_level)


	ring_count = get_tree().get_nodes_in_group("Rings").size()
	print_debug("Ring count is %d" % ring_count)
	hud_controller.set_rings(ring_count)

	get_spawnpoints()

	get_exit_gate()

	get_camera()

	respawn_player()



	update_save()


	switch_ui(Screens.HUD)

func get_camera():
	camera = get_tree().get_first_node_in_group("Camera") as PlayerCamera

func connect_camera_with_player():
	assert (camera != null)
	camera.connect_player(ball as Player)

func update_save():
	var save_data = SaveManager.save_data
	if save_data["level_reached"] < current_level_index:
		SaveManager.save_data["level_reached"] = current_level_index
	if save_data["highscore"] < score:
		SaveManager.save_data["highscore"] = score
	SaveManager.save_game()

func update_score_hud(add: int):
	score += add
	hud_controller.update_score(score)

func respawn_player():
	print_debug("Respawning...")
	if ball != null:
		ball.free()
	ball = ball_scene.instantiate()
	assert (camera != null)
	camera.reset()
	camera.connect_player(ball as Player)
	ball.global_position = active_spawnpoint.global_position
	current_level.add_child(ball)
	if active_spawnpoint.init_big:
		ball.inflate()
	else:
		ball.deflate()

func handle_bubble_collected():
	print_debug("Bubble collected")


	$AudioManager.play_sfx(AudioManager.SFX.Secondary)

	if life_count < 6:
		hud_controller.add_life()
		life_count += 1

	update_score_hud(bubble_score)

func set_checkpoint(sender: Marker2D):

	$AudioManager.play_sfx(AudioManager.SFX.Secondary)

	active_spawnpoint = sender
	update_score_hud(checkpoint_score)
	print_debug(active_spawnpoint)

func handle_player_death():
	if not ball.has_method("die"):
		return


	$AudioManager.play_sfx(AudioManager.SFX.Death)

	if life_count <= 0:
		if ball.die():
			call_deferred("unload_current_level")
			transition_screen.score = score
			transition_screen.set_game_over()
			switch_ui(Screens.Transition)
	elif ball.die():
		hud_controller.remove_life()
		life_count -= 1
		respawn_timer.start(respawn_time)

func handle_collect_ring():
	if ring_count <= 0:
		push_error("Cannot collect a ring when there are none left.")
		return


	$AudioManager.play_sfx(AudioManager.SFX.Collect)

	hud_controller.remove_ring()
	ring_count -= 1
	update_score_hud(ring_score)

	if ring_count <= 0:

		exit_gate.open_gate()
