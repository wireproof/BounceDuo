class_name LevelButton
extends Button

var level_number: int


func _ready():
	text = str(level_number)
	pressed.connect(_on_pressed)

func _on_pressed():
	EventBus.play_level.emit(level_number)
