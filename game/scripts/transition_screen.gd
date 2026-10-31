class_name TransitionScreen
extends Control

signal next_level
signal game_over

var score: int = 0
var level: int = 0

var is_game_over: bool = false

func set_label(text: String):
	$MarginContainer / Label.text = text + "\nScore: %07d" % score

func update_label():
	$MarginContainer / Label.text = "Level %d completed!\nScore: %07d" % [level, score]

func set_game_over():
	$MarginContainer / Label.text = "Game Over.\nScore: %07d" % score
	$MarginContainer / ContinueButton.text = "Back"
	is_game_over = true

func reset():
	$MarginContainer / ContinueButton.text = "Continue"
	is_game_over = false

func _on_continue_button_pressed():
	if is_game_over:
		game_over.emit()
	else:
		next_level.emit()
