extends EnemyHandler
class_name PainterEnemy

func _ready():
	_update_label()

func on_enemy_turn():
	var grid = levelGrid
	if grid == null:
		return

	# Paint adjacent blocks randomly
	var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for d in dirs:
		var nx = bPosition.x + d.x
		var ny = bPosition.y + d.y
		if nx >= 0 and nx < grid.grid_size.x and ny >= 0 and ny < grid.grid_size.y:
			var neighbor = grid.blocks[ny][nx]
			if neighbor != null and neighbor.bType == BlockType.Block:
				neighbor._set_color(randi_range(0, neighbor.palletes.size() - 1))

	# Move left or right after painting
	var dir = -1 if randf() < 0.5 else 1
	var new_x = clamp(bPosition.x + dir, 0, grid.grid_size.x - 1)
	if grid.blocks[bPosition.y][new_x] == null:
		grid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x = new_x
		grid.blocks[bPosition.y][bPosition.x] = self
		grid.setPositionOfBlockOnBoard(self)
