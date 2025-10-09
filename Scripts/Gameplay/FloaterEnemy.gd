extends EnemyHandler
class_name FloaterEnemy

func _ready():
	super._ready()  # setup from EnemyHandler

	var grid = levelGrid
	var col = randi_range(0, grid.grid_size.x - 1)
	var spawn_height = randi_range(int(grid.grid_size.y * 0.75), grid.grid_size.y - 1)

	while grid.blocks[spawn_height][col] != null:
		col = randi_range(0, grid.grid_size.x - 1)
		spawn_height = randi_range(int(grid.grid_size.y * 0.75), grid.grid_size.y - 1)

	bPosition = Vector2i(col, spawn_height)
	grid.blocks[bPosition.y][bPosition.x] = self
	grid.setPositionOfBlockOnBoard(self)

func on_enemy_turn():
	var grid = levelGrid
	var dir = -1 if randf() < 0.5 else 1
	var new_x = clamp(bPosition.x + dir, 0, grid.grid_size.x - 1)

	if grid.blocks[bPosition.y][new_x] == null:
		grid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x = new_x
		grid.blocks[bPosition.y][bPosition.x] = self
		grid.setPositionOfBlockOnBoard(self)
