extends EnemyHandler
class_name PainterEnemy

func on_enemy_turn() -> void:
	if levelGrid == null:
		return

	# paint neighbors (use safe typing)
	var didPaint = false
	var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for d in dirs:
		var nx: int = bPosition.x + d.x
		var ny: int = bPosition.y + d.y
		if nx >= 0 and nx < levelGrid.grid_size.x and ny >= 0 and ny < levelGrid.grid_size.y:
			var neighbor = levelGrid.blocks[ny][nx]
			if neighbor != null and neighbor.bType == BlockType.Block:
				# choose a random valid palette index on the neighbor
				if neighbor.palletes != null and neighbor.palletes.size() > 0:
					#every time the painter successfully paints, it gains one health
					didPaint = true
					take_damage(-1)
					var idx = randi_range(0, neighbor.palletes.size() - 1)
					neighbor._set_color(idx)
	#checks for if the painter painted after trying to paint
	if(!didPaint):
		take_damage(1)

	# attempt move left or right after painting
	var dir = -1 if randf() < 0.5 else 1
	var new_x = clamp(bPosition.x + dir, 0, levelGrid.grid_size.x - 1)
	if levelGrid.blocks[bPosition.y][new_x] == null:
		levelGrid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x = new_x
		levelGrid.blocks[bPosition.y][bPosition.x] = self
		levelGrid.setPositionOfBlockOnBoard(self)
