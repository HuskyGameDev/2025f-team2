extends Button

#set this var to whatever scene you want this button to send you to
@export var targetScene: String = "res://Scenes/WorldMap/worldMap.tscn"

func _ready() -> void:
	grab_focus()

#When the button is pressed, loads the next scene
func _on_pressed() -> void:
	get_tree().paused = false
	if(get_node("/root/Level") != null):
		GlobalSceneLoader.load_level(targetScene, null, get_node("/root/Level").currentLevelState.worldMapPos)
	else:
		GlobalSceneLoader.load_level(targetScene, null, 0)
	
