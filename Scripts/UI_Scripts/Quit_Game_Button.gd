extends Button

#When the quit button is pressed on the main menu, quit the game
func _on_pressed() -> void:
	get_tree().quit()
