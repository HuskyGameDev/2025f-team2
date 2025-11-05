extends Node

class_name WinLose
#attached to the win lose screen, call the correct function, this will handle it

@export var panel: Panel
@export var canvas: CanvasLayer

@export var winScreen: Node

func winGame():
	panel.visible = true
	canvas.visible = true
	get_tree().paused = true
	winScreen.visible = true

@export var loseScreen: Node

func loseGame():
	panel.visible = true
	canvas.visible = true
	get_tree().paused = true
	loseScreen.visible = true
