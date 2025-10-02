extends EnemyHandler
class_name PainterEnemy

func _ready():
	var label = get_node_or_null("Label")
	if label:
		label.text = "P"

func on_player_block_placed():
	var grid = levelGrid
	var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]

	# paint neighboring blocks
	for d in dirs:
		var nx = bPosition.x + d.x
		var ny = bPosition.y + d.y
		if nx >= 0 and nx < grid.grid_size.x and ny >= 0 and ny < grid.grid_size.y:
			var neighbor = grid.blocks[ny][nx]
			if neighbor != null and neighbor.bType == BoxHandler.BlockType.Block:
				neighbor._set_color(randi_range(0, neighbor.palletes.size() - 1))

	# move to new lowest spot in a random column
	var col = randi_range(0, grid.grid_size.x - 1)
	var pos = grid.get_lowest_free_position(col)
	if pos.y != -1:
		grid.blocks[bPosition.y][bPosition.x] = null
		bPosition = pos
		grid.blocks[bPosition.y][bPosition.x] = self
		grid.setPositionOfBlockOnBoard(self)
