extends Sprite2D

@export var startingDegrees = 0.0
@export var rotAmount = 7.0
@export var gravity = 8.0
@export var speed = 2.0
var maxY = 270.0

var eTime : float

func _ready() -> void:
	startingDegrees = rotation_degrees

func _process(delta: float) -> void:
	eTime += delta*speed
	var displace : float = sin(eTime) * rotAmount
	rotation_degrees = startingDegrees + displace
	global_position += Vector2(gravity, gravity) * delta
	if global_position.y > maxY:
		queue_free()
