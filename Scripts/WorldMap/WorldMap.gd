extends Node3D

@export var camera : WorldCamera
@export var uiScreen : LevelSelectUI
@export var worldPoints : Array[WorldPoint]

var vaild : bool = true
var pos : int = 0

func _ready() -> void:
	sets()

func _input(event: InputEvent) -> void:
	if !vaild:
		return
	if event.is_action_released("left"):
		previous()
		await sets()
	if event.is_action_released("right"):
		next()
		await sets()

func next():
	pos += 1
	if pos >= len(worldPoints):
		pos = 0

func previous():
	pos -= 1
	if pos < 0:
		pos = len(worldPoints) - 1

func sets():
	vaild = false
	await uiScreen.animationUp()
	camera.setPositionOfCameraFromPoint(worldPoints[pos])
	await uiScreen.animationUp()
	uiScreen.setNameLabel(worldPoints[pos].level.levelName)
	uiScreen.setScreen(worldPoints[pos].level.img)
	await uiScreen.animationDown()
	vaild = true
	
