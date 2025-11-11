extends Node

class_name WinLose
#attached to the win lose screen, call the correct function, this will handle it

@export var panel: Panel
@export var canvas: CanvasLayer
@export var pauseMenu : PauseMenu

@export var winScreen: Node

func winGame():
	pauseMenu.canPause = false
	panel.visible = true
	canvas.visible = true
	$CanvasLayer/Winning/WorldMap.grab_focus()
	if get_tree().paused == false:
		get_tree().paused = true
	winScreen.visible = true

@export var loseScreen: Node

func loseGame():
	pauseMenu.canPause = false
	panel.visible = true
	canvas.visible = true
	$CanvasLayer/Losing/Restart.grab_focus()
	if get_tree().paused == false:
		get_tree().paused = true
	loseScreen.visible = true
