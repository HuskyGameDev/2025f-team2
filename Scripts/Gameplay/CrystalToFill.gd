extends Sprite2D
class_name Crystal
signal on_die

var speed_down : float = 20
var block : BoxFiller


func _ready() -> void:
	speed_down = randf_range(20, 40)
	frame = randi_range(0, 5)
	var rotTimer = Timer.new()
	rotTimer.autostart = true
	rotTimer.wait_time = 0.25
	rotTimer.timeout.connect(rotme)
	add_child(rotTimer)


func rotme():
	rotation_degrees += 45

func _process(delta: float) -> void:
	position.y += speed_down * delta
	speed_down += speed_down * 1.5 * delta
	if position.y >= 0:
		if block.fblock != null:
			if !block.fblock.placed:
				on_die.emit()
		queue_free()
