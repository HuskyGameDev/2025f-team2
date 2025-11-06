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
	if event.is_action_released("release"):
		enterLevel()
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
	await uiScreen.wait()
	uiScreen.setNameLabel(worldPoints[pos].level.levelName)
	uiScreen.setTypeLabel(worldPoints[pos].level.getLevelTypeName(worldPoints[pos].level.levelType))
	await uiScreen.animationDown()
	vaild = true

func enterLevel():
	vaild = false
	await uiScreen.animationUp()
	#camera.setPositionOfCameraInCutscene(worldPoints[pos])
	await create_tween().tween_property(camera, "rotation_degrees:x", 90, 0.25).finished
	await uiScreen.wait()
	GlobalSceneLoader.load_level(worldPoints[pos].level.scene)
