extends BoxHandler

var side = "left"

func _init() -> void:
	bType = BlockType.Arrow

func _ready() -> void:
	super._ready()
	var sided = randi_range(0,1)
	if sided == 0:
		side = "left"
		flip_h = false
	elif sided == 1:
		side = "right"
		flip_h = true

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
	placed = true

func _addToBlock():
	return

func moveNext():
	levelGrid.blocks[bPosition.y][bPosition.x] = null
	placed = true
	if side == "left":
		levelGrid.move_all_blocks_left()
	elif side == "right":
		levelGrid.move_all_blocks_right()
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
