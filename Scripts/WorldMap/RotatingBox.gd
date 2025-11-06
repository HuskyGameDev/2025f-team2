extends Node2D

@export var sign : float = 1.0
var speed = 90.0

var palletes : Array[ShaderMaterial] = [load("res://Materials/Palletes/GreenBox.tres"), load("res://Materials/Palletes/RedBox.tres"), load("res://Materials/Palletes/YellowBox.tres")]

func _ready() -> void:
	material = palletes.pick_random()

func _process(delta: float) -> void:
	rotation_degrees += speed * sign * delta
