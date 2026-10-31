class_name PlayerCamera
extends Camera2D

@export var limit_marker: Marker2D

var player: Player

var current_height: = 0
const TILE_SIZE: = 12
const MOVE_TILES: = 7

func _ready():
	if limit_marker:
		limit_right = limit_marker.global_position.x
	else:
		push_warning("No limit marker set for camera ", self)

func _process(_delta):
	if player != null:
		global_position = player.global_position.round()
		var player_height = player.global_position.y
		var top_boundary = (current_height * MOVE_TILES * TILE_SIZE) + (TILE_SIZE / 2)
		var bottom_boundary = ((current_height + 1) * MOVE_TILES * TILE_SIZE) + (TILE_SIZE / 2)
		if player_height < top_boundary - 1:
			move_up()
		elif player_height > bottom_boundary + 1:
			move_down()

func connect_player(_player: Player):
	player = _player

func reset():
	current_height = 0
	offset.y = 0

func move_up():
	offset.y -= TILE_SIZE * MOVE_TILES
	current_height -= 1

func move_down():
	offset.y += TILE_SIZE * MOVE_TILES
	current_height += 1
