extends Button

#This script gives functionality to the "Resume" button in the pause menu
func _on_pressed() -> void:
	get_parent().get_parent()._pausePressed()
	get_parent().get_parent().visible=false
	get_tree().paused = false
