extends Control

class_name LevelSelectUI

@export var nameLabel : Label
@export var screen : TextureRect

func setNameLabel(name:String):
	nameLabel.text = name

func setScreen(text:Texture2D):
	screen.texture = text

func animationUp():
	await create_tween().tween_property(self, "position", Vector2(80, -81.0), 0.25).finished

func animationDown():
	await create_tween().tween_property(self, "position", Vector2(80, 0), 0.25).finished

func wait():
	await create_tween().tween_property(self, "position", Vector2(80, -81.0), 0.05).finished
