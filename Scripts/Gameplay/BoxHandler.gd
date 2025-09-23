extends Sprite2D
class_name BoxHandler

enum BlockColor{Green, Red}

enum BlockType{Block, Arrow}

@export var palletes : Array[Material]

var blockValue : int = 0
var levelGrid : LevelGrid

var bPosition : Vector2i

var bColor : BlockColor = BlockColor.Green
var bType : BlockType = BlockType.Block

var placed : bool

func _ready() -> void:
	material = palletes[bColor]
	_updateBoxText()
	
func _onFallTick():
	if placed:
		return
	levelGrid.moveBlockDown(self)

func _updateBoxText():
	$Label.text = str(blockValue)

func _set_color(col : int):
	bColor = col
	material = palletes[bColor]

func _addToBlock():
	blockValue += 1
	_updateBoxText()

func mergeBox(downBlock:BoxHandler):
	downBlock.blockValue += blockValue
	downBlock._updateBoxText()
	levelGrid.blocks[bPosition.y][bPosition.x] = null
	queue_free()

func moveDown(control : bool = true):
	if (bPosition.y - 1) < 0:
		await levelGrid.place_block(self)
		if control:
			levelGrid.next_block()
		return
	if levelGrid.blocks[bPosition.y-1][bPosition.x] != null && levelGrid.blocks[bPosition.y][bPosition.x] != null:
		if levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y-1][bPosition.x]):
			levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y-1][bPosition.x])
			levelGrid.next_block()
			return
		else:
			await levelGrid.place_block(self)
			if control:
				levelGrid.next_block()
		return
	#move Block Downwards
	levelGrid.blocks[bPosition.y][bPosition.x] = null
	bPosition.y -= 1
	levelGrid.blocks[bPosition.y][bPosition.x] = self
	levelGrid.setPositionOfBlockOnBoard(self)

func moveLeft(merge : bool = false):
	if (bPosition.x - 1) < 0:
		return
	if levelGrid.blocks[bPosition.y][bPosition.x-1] != null:
		if merge:
			if levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x-1]):
				levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x-1])
		return
	#move Block Downwards
	levelGrid.blocks[bPosition.y][bPosition.x] = null
	bPosition.x -= 1
	levelGrid.blocks[bPosition.y][bPosition.x] = self
	levelGrid.setPositionOfBlockOnBoard(self)

func moveRight(merge : bool = false):
	if (bPosition.x + 1) > levelGrid.grid_size.x - 1:
		return
	if levelGrid.blocks[bPosition.y][bPosition.x+1] != null:
		if merge:
			if levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x+1]):
				levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x+1])
		return
	#move Block Downwards
	levelGrid.blocks[bPosition.y][bPosition.x] = null
	bPosition.x += 1
	levelGrid.blocks[bPosition.y][bPosition.x] = self
	levelGrid.setPositionOfBlockOnBoard(self)

func hardDrop():
	var y = levelGrid.grid_size.y-1
	while(y >= 0):
		if y == 0:
			levelGrid.blocks[bPosition.y][bPosition.x] = null
			bPosition.y = y
			levelGrid.blocks[bPosition.y][bPosition.x] = self
			levelGrid.setPositionOfBlockOnBoard(self)
			await levelGrid.place_block(self)
			levelGrid.next_block()
			return
		if levelGrid.blocks[y-1][bPosition.x] == null or levelGrid.blocks[y-1][bPosition.x].placed == false:
			y -= 1
		else:
			if levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[y-1][bPosition.x]):
				levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[y-1][bPosition.x])
				levelGrid.next_block()
				return
			else:
				levelGrid.blocks[bPosition.y][bPosition.x] = null
				bPosition.y = y
				levelGrid.blocks[bPosition.y][bPosition.x] = self
				levelGrid.setPositionOfBlockOnBoard(self)
				await levelGrid.place_block(self)
				levelGrid.next_block()
				return

func placeBlock():
	placed = true
