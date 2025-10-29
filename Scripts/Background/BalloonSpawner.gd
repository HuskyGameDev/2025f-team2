extends Node2D

@export var objectToSpawn : PackedScene

var next : float = -60

func _ready() -> void:
	var timed = Timer.new()
	timed.timeout.connect(spawnObject)
	timed.one_shot = false
	timed.autostart = true
	add_child(timed)
	timed.wait_time = 4.0

func spawnObject():
	print("newBalloon")
	var object : Node2D = objectToSpawn.instantiate()
	add_child(object)
	
	object.position.x = next
	next += randf_range(90, 110)
	if next > 320.0:
		next -= (320.0 + randf_range(0, 70))
	object.position.y = 0
