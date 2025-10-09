extends Sprite2D
class_name Crystal

signal on_die

var speed_down: float = 20
var block_filler: BoxFiller   # updated name to match BoxFiller script

func _ready() -> void:
	speed_down = randf_range(20, 40)
	frame = randi_range(0, 5)

	var rot_timer = Timer.new()
	rot_timer.autostart = true
	rot_timer.wait_time = 0.25
	rot_timer.timeout.connect(_on_rotate_timer_timeout)
	add_child(rot_timer)

func _on_rotate_timer_timeout():
	rotation_degrees += 45

func _process(delta: float) -> void:
	position.y += speed_down * delta
	speed_down += speed_down * 1.5 * delta

	if position.y >= 0:
		if block_filler != null and is_instance_valid(block_filler):
			if block_filler.fblock != null and is_instance_valid(block_filler.fblock):
				if not block_filler.fblock.placed:
					on_die.emit()
		queue_free()
