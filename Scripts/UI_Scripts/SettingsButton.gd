# SettingsButton.gd
extends Button

#set this var to whatever scene you want this button to send you to
@export var targetScene: String = "res://Scenes/TestScenes/SettingsMenu.tscn";

func _ready() -> void:
	if name == "PlayGame":
		grab_focus()

#When the button is pressed, loads the next scene
func _on_pressed() -> void:
	get_tree().paused = false
	GlobalSceneLoader.load_level(targetScene)
