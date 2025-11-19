extends EnemyHandler
class_name FloaterEnemy

var dir = 1

func _ready() -> void:
	super._ready()
	# Ensure enemy sprite shows up properly
	if palletes.size() > 0:
		_set_color(color_index)
	modulate = Color(1, 1, 1, 1)
	visible = true
	print("Min action speed: " + str(action_min_seconds))
	print("Max action speed: " + str(action_max_seconds))

func on_enemy_turn() -> void:
	if levelGrid == null:
		return
	#action_timer.wait_time = randf_range(action_min_seconds, action_max_seconds)

	#enable this code for random direction:
	#var dir = -1 if randf() < 0.5 else 1
	
	var new_x = clamp(bPosition.x + dir, 0, levelGrid.grid_size.x - 1)
	
	# only move if space is empty
	if levelGrid.blocks[bPosition.y][new_x] != null || (dir == -1 && bPosition.x == 0) || (dir == 1 && bPosition.x == levelGrid.grid_size.x):
		print("turnaround")
		dir *= -1
		new_x = clamp(bPosition.x + dir, 0, levelGrid.grid_size.x - 1)
		
	if levelGrid.blocks[bPosition.y][new_x] == null:
		levelGrid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x = new_x
		levelGrid.blocks[bPosition.y][bPosition.x] = self
		levelGrid.setPositionOfBlockOnBoard(self)
	
