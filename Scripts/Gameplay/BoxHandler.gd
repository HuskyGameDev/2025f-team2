extends Sprite2D
class_name BoxHandler

enum BlockColor{Green, Red, Yellow}

enum BlockType{Block, Arrow, Indestructible}

@export var palletes : Array[Material]

var blockValue : int = 0
var levelGrid : LevelGrid

var bPosition : Vector2i

var bColor : BlockColor = BlockColor.Green
var bType : BlockType = BlockType.Block

var placed : bool
var floating : bool = true

func _ready() -> void:
	material = palletes[bColor]
	_updateBoxText()
	
func _onFallTick():
	if floating:
		return
	if bType == BlockType.Block:
		if levelGrid.get_all_blocks_in_board().find(self) == -1:
			print("father help "+ str(bColor) + " " + str(blockValue))
		levelGrid.setPositionOfBlockOnBoard(self)
	if bPosition.y-1 >= 0:
		if levelGrid.blocks[bPosition.y-1][bPosition.x] == null:
			placed = false
		elif levelGrid.blocks[bPosition.y-1][bPosition.x] != null:
			levelGrid.moveBlockDown(self, levelGrid.active_block == self)
			return
	if placed:
		return
	levelGrid.moveBlockDown(self, levelGrid.active_block == self)

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
	if levelGrid.blocks[bPosition.y-1][bPosition.x] != null:
		if levelGrid.blocks[bPosition.y-1][bPosition.x].bType == BlockType.Indestructible:
			if control:
				await levelGrid.place_block(self)
				levelGrid.next_block()
			return
		elif levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y-1][bPosition.x]):
			levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y-1][bPosition.x])
			if control:
				levelGrid.next_block()
		else:
			if control:
				await levelGrid.place_block(self)
				levelGrid.next_block()
		return
	#move Block Downwards
	if bType != BlockType.Arrow:
		levelGrid.blocks[bPosition.y][bPosition.x] = null
		bPosition.y -= 1
		levelGrid.blocks[bPosition.y][bPosition.x] = self
		levelGrid.setPositionOfBlockOnBoard(self)
		return
	else:
		bPosition.y -= 1
		levelGrid.setPositionOfBlockOnBoard(self)
		return


func moveLeft(merge : bool = false):
	if (bPosition.x - 1) < 0:
		return
	if levelGrid.blocks[bPosition.y][bPosition.x-1] != null:
		if merge:
			if levelGrid.blocks[bPosition.y][bPosition.x-1].bType == BlockType.Indestructible:
				return
			if levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x-1]):
				levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x-1])
			return
		else:
			return
	#move Block Left
	if bType != BlockType.Arrow:
		levelGrid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x -= 1
		levelGrid.blocks[bPosition.y][bPosition.x] = self
		levelGrid.setPositionOfBlockOnBoard(self)
		return
	else:
		bPosition.x -= 1
		levelGrid.setPositionOfBlockOnBoard(self)
		return

func moveRight(merge : bool = false):
	if (bPosition.x + 1) > levelGrid.grid_size.x - 1:
		return
	if levelGrid.blocks[bPosition.y][bPosition.x+1] != null:
		if merge:
			if levelGrid.blocks[bPosition.y][bPosition.x+1].bType == BlockType.Indestructible:
				return
			if levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x+1]):
				levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x+1])
			return
		else:
			return
	#move Block Right
	if bType != BlockType.Arrow:
		levelGrid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x += 1
		levelGrid.blocks[bPosition.y][bPosition.x] = self
		levelGrid.setPositionOfBlockOnBoard(self)
		return
	else:
		bPosition.x += 1
		levelGrid.setPositionOfBlockOnBoard(self)
		return

func hardDrop():
	var y =  bPosition.y
	while(y >= 0):
		if y == 0:
			levelGrid.blocks[bPosition.y][bPosition.x] = null
			bPosition.y = y
			levelGrid.blocks[bPosition.y][bPosition.x] = self
			levelGrid.setPositionOfBlockOnBoard(self)
			await levelGrid.place_block(self)
			levelGrid.next_block()
			return
		if (levelGrid.blocks[y-1][bPosition.x] == null):
			y -= 1
		elif levelGrid.blocks[y-1][bPosition.x].bType == BlockType.Arrow:
			y -= 1
		elif levelGrid.blocks[y-1][bPosition.x].bType == BlockType.Indestructible:
			levelGrid.blocks[bPosition.y][bPosition.x] = null
			bPosition.y = y
			levelGrid.blocks[bPosition.y][bPosition.x] = self
			levelGrid.setPositionOfBlockOnBoard(self)
			await levelGrid.place_block(self)
			levelGrid.next_block()
			return
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

func onAdd():
	placed = false
	floating = false
