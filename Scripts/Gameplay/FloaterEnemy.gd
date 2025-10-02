extends EnemyHandler
class_name FloaterEnemy

var move_dir := 1

func _ready():
	pass
	#$Label.text = str("F")

func on_player_block_placed():
	var grid = levelGrid
	var dir = -1 if randf() < 0.5 else 1
	var new_x = clamp(bPosition.x + dir, 0, grid.grid_size.x - 1)
	if grid.blocks[bPosition.y][new_x] == null:
		grid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x = new_x
		grid.blocks[bPosition.y][bPosition.x] = self
		grid.setPositionOfBlockOnBoard(self)
