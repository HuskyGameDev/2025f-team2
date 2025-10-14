extends Node2D

@export var distance = 5.0
@export var timeAdd = 0.0

var startingy : float

var eTime : float

func _ready() -> void:
	startingy = position.y
	eTime += timeAdd

func _process(delta: float) -> void:
	eTime += delta
	var displace : float = sin(eTime) * distance
	position.y = startingy + displace
