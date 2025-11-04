extends EnemyHandler
class_name FloaterEnemy

func _ready() -> void:
	#check for if there is an enemy stats resource
	if(enemyStats != null):
		#sets max to the higher and min to the lower
		if(enemyStats.floaterHealth.y > enemyStats.floaterHealth.x):
			min_health = enemyStats.floaterHealth.x
			max_health = enemyStats.floaterHealth.y
		else:
			min_health = enemyStats.floaterHealth.y
			max_health = enemyStats.floaterHealth.x
			
		if(enemyStats.floaterActionSpeed.y > enemyStats.floaterActionSpeed.x):
			action_min_seconds = enemyStats.floaterActionSpeed.x
			action_max_seconds = enemyStats.floaterActionSpeed.y
		else:
			action_min_seconds = enemyStats.floaterActionSpeed.y
			action_max_seconds = enemyStats.floaterActionSpeed.x
	else:
		print("No enemy stats resource")
	
	#if either health range has been set to under 1, default to 1
	if(min_health < 1):
		min_health = 1
	if(max_health < 1):
		max_health = 1
	super._ready()
	# Ensure enemy sprite shows up properly
	if palletes.size() > 0:
		_set_color(color_index)
	modulate = Color(1, 1, 1, 1)
	visible = true

func on_enemy_turn() -> void:
	if levelGrid == null:
		return

	var dir = -1 if randf() < 0.5 else 1
	var new_x = clamp(bPosition.x + dir, 0, levelGrid.grid_size.x - 1)

	# only move if space is empty
	if levelGrid.blocks[bPosition.y][new_x] == null:
		levelGrid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x = new_x
		levelGrid.blocks[bPosition.y][bPosition.x] = self
		levelGrid.setPositionOfBlockOnBoard(self)
