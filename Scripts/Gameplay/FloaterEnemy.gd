extends EnemyHandler
class_name FloaterEnemy

func _ready():
	var grid = levelGrid
	var col = randi_range(0, grid.grid_size.x - 1)

	# restrict to upper portion of the grid (e.g., top 25%)
	var spawn_height = randi_range(int(grid.grid_size.y * 0.75), grid.grid_size.y - 1)

	# make sure chosen cell is empty
	while grid.blocks[spawn_height][col] != null:
		col = randi_range(0, grid.grid_size.x - 1)
		spawn_height = randi_range(int(grid.grid_size.y * 0.75), grid.grid_size.y - 1)

	bPosition = Vector2i(col, spawn_height)

	# place in grid
	grid.blocks[bPosition.y][bPosition.x] = self
	grid.setPositionOfBlockOnBoard(self)

func on_player_block_placed():
	var grid = levelGrid

	# random left/right
	var dir = -1 if randf() < 0.5 else 1
	var new_x = clamp(bPosition.x + dir, 0, grid.grid_size.x - 1)

	# move only if free
	if grid.blocks[bPosition.y][new_x] == null:
		grid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x = new_x
		grid.blocks[bPosition.y][bPosition.x] = self
		grid.setPositionOfBlockOnBoard(self)
