extends BoxHandler
class_name FloaterEnemy

var move_dir := 1 # start moving right

func _ready():
	bType = BoxHandler.BlockType.Enemy
	$Label.text = "F"
	var grid = get_parent().boxGrid
	var col = randi_range(0, grid.grid_size.x - 1)
	bPosition = Vector2i(col, grid.grid_size.y - 2)

func on_player_block_placed():
	var grid = levelGrid
	var dir = -1 if randf() < 0.5 else 1
	var new_x = clamp(bPosition.x + dir, 0, grid.grid_size.x - 1)

	if grid.blocks[bPosition.y][new_x] == null:
		grid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x = new_x
		grid.blocks[bPosition.y][bPosition.x] = self
		grid.setPositionOfBlockOnBoard(self)

func on_block_collision(block: BoxHandler):
	# add health logic
	pass
