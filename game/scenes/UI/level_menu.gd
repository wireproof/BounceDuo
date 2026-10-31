extends MarginContainer

var level_button_scn = preload("res://scenes/UI/level_button.tscn")
var total_level_count: int = 11


func _ready():
	add_level_buttons()

func add_level_buttons():
	remove_children($VBoxContainer / GridContainer)

	SaveManager.load_game()

	var level_reached = SaveManager.save_data["level_reached"]
	for index in total_level_count:
		var level_button: LevelButton = level_button_scn.instantiate()
		level_button.level_number = index + 1
		if index > level_reached:
			level_button.disabled = true
		$VBoxContainer / GridContainer.add_child(level_button)

func remove_children(node: Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func connect_back(return_to_menu: Callable):
	$VBoxContainer / LevelsBackButton.pressed.connect(return_to_menu)
