extends Node2D
class_name RibbonAnimator

@onready var animatior = $AnimationPlayer

func setIdle():
	animatior.play("idle")

func setGetBox():
	animatior.play("getBox")

func setHop():
	animatior.play("Hop")

func waitUntilFinish():
	await animatior.animation_finished
