extends Button

#When the "Play-Game" button is pressed, loads the next scene
func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/TestScenes/TestScene.tscn")
