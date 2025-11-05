extends Control

class_name LevelSelectUI

@export var nameLabel : Label
@export var typeLabel : Label

func setNameLabel(name:String):
	nameLabel.text = name

func setTypeLabel(name:String):
	typeLabel.text = name

func animationUp():
	await create_tween().tween_property(self, "position", Vector2(80, -81.0), 0.25).finished

func animationDown():
	await create_tween().tween_property(self, "position", Vector2(80, 0), 0.25).finished

func wait():
	await create_tween().tween_property(self, "position", Vector2(80, -81.0), 0.05).finished
