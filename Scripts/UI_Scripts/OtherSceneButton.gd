extends Button

#set this var to whatever scene you want this button to send you to
@export var targetScene: String = "res://Scenes/TestScenes/TestScene.tscn";

#When the button is pressed, loads the next scene
func _on_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(targetScene)
