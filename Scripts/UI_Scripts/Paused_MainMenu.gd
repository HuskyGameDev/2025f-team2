extends Node

#This script gives functionality to the "Main menu" button in the pause menu
func _on_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/TestScenes/MainMenu.tscn")
