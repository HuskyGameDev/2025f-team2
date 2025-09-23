extends BoxHandler

func _init() -> void:
	bType = BlockType.Arrow

func _updateBoxText():
	$Label.text = ""

func moveLeft(merge : bool = false):
	merge = false
	super.moveLeft(merge)

func moveRight(merge : bool = false):
	merge = false
	super.moveRight(merge)

func mergeBox(downBlock:BoxHandler):
	return

func placeBlock():
	moveNext()

func _addToBlock():
	return

func hardDrop():
	var y = levelGrid.grid_size.y-1
	while(y >= 0):
		if y == 0:
			levelGrid.blocks[bPosition.y][bPosition.x] = null
			bPosition.y = y
			levelGrid.blocks[bPosition.y][bPosition.x] = self
			levelGrid.setPositionOfBlockOnBoard(self)
			moveNext()
			return
		if levelGrid.blocks[y-1][bPosition.x] == null or levelGrid.blocks[y-1][bPosition.x].placed == false:
			y -= 1
		else:
			if levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[y-1][bPosition.x]):
				levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[y-1][bPosition.x])
				moveNext()
				return
			else:
				levelGrid.blocks[bPosition.y][bPosition.x] = null
				bPosition.y = y
				levelGrid.blocks[bPosition.y][bPosition.x] = self
				levelGrid.setPositionOfBlockOnBoard(self)
				moveNext()
				return

func moveNext():
	levelGrid.blocks[bPosition.y][bPosition.x] = null
	placed = true
	levelGrid.move_all_blocks_left()
	await levelGrid.next_block()
	queue_free()

func moveDown(control : bool = true):
	if (bPosition.y - 1) < 0:
		if control:
			moveNext()
		return
	if levelGrid.blocks[bPosition.y-1][bPosition.x] != null:
		if control:
			moveNext()
		return
	#move Block Downwards
	levelGrid.blocks[bPosition.y][bPosition.x] = null
	bPosition.y -= 1
	levelGrid.blocks[bPosition.y][bPosition.x] = self
	levelGrid.setPositionOfBlockOnBoard(self)
