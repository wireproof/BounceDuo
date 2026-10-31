
extends Node

const save_path = "user://savegame.save"
var save_data: Dictionary = {
	"level_reached": 0, 
	"highscore": 0, 
}

func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var json_string = JSON.stringify(save_data)
	file.store_line(json_string)
	file.close()

func load_game():
	if not FileAccess.file_exists(save_path):
		return

	var file = FileAccess.open(save_path, FileAccess.READ)

	while file.get_position() < file.get_length():
		var json_string = file.get_line()
		var json: = JSON.new()

		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			push_error("JSON Parse Error")
			continue

		save_data = json.data
