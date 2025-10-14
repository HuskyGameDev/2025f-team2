extends EnemyHandler
class_name PainterEnemy

func on_enemy_turn():
	if levelGrid == null:
		return

	# paint neighbors
	var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for d in dirs:
		var nx: int = bPosition.x + d.x
		var ny: int = bPosition.y + d.y
		if nx >= 0 and nx < levelGrid.grid_size.x and ny >= 0 and ny < levelGrid.grid_size.y:
			var neighbor: BoxHandler = levelGrid.blocks[ny][nx]
			if neighbor != null and neighbor.bType == BlockType.Block:
				neighbor._set_color(randi_range(0, neighbor.palletes.size()-1))

	# move left/right like Floater
	var dir = -1 if randf() < 0.5 else 1
	var new_x = clamp(bPosition.x + dir, 0, levelGrid.grid_size.x-1)
	if levelGrid.blocks[bPosition.y][new_x] == null:
		levelGrid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x = new_x
		levelGrid.blocks[bPosition.y][bPosition.x] = self
		levelGrid.setPositionOfBlockOnBoard(self)
