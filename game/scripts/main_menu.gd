extends Control
class_name MainMenu

signal new_game
signal continue_game

enum Screens{
	MainMenu, 
	Highscore, 
	Instructions, 
	Levels
}

var current_screen: Screens = Screens.MainMenu

func _ready():
	$LevelMenu.connect_back(return_to_main_menu)

func set_screen_visible(screen: Screens, visible: bool):
	match screen:
		Screens.MainMenu:
			$MenuScreen.visible = visible
		Screens.Highscore:
			var highscore: int = SaveManager.save_data["highscore"]
			$HighscoreScreen / HighscoreLabel.text = "High Score: %07d" % highscore
			$HighscoreScreen.visible = visible
		Screens.Instructions:
			$InstructionsScreen.visible = visible
		Screens.Levels:
			$LevelMenu.add_level_buttons()
			$LevelMenu.visible = visible

func switch_screen(dest: Screens):
	if current_screen == dest:
		return

	set_screen_visible(current_screen, false)
	set_screen_visible(dest, true)

	current_screen = dest

func _on_continue_button_pressed():
	continue_game.emit()

func _on_new_game_button_pressed():
	if SaveManager.save_data["level_reached"] == 0:
		new_game.emit()
		return
	switch_screen(Screens.Levels)

func _on_high_score_button_pressed():
	SaveManager.load_game()
	switch_screen(Screens.Highscore)

func _on_instructions_button_pressed():
	switch_screen(Screens.Instructions)

func return_to_main_menu():
	switch_screen(Screens.MainMenu)

func _on_exit_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
