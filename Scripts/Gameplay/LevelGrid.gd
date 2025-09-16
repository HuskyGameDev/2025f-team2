extends Node2D

class_name LevelGrid

var block_node = load("res://Scenes/GameObjects/box.tscn")

@export var levelManager : LevelManager 

@export var grid_space : int
@export var grid_size : Vector2i

var active_block : BoxHandler

var blocks = []

func _ready() -> void:
	for i in grid_size.y:
		blocks.append([])
		for j in grid_size.x:
			blocks[i].append(null) # Set a starter value for each position

func addBlock(block : BoxHandler):
	block.placed = false
	block.levelGrid = self
	block.get_parent().remove_child(block)
	add_child(block)
	blocks[block.bPosition.y][block.bPosition.x] = block
	levelManager.fallTimer.timeout.connect(block._onFallTick)
	setActiveBlock(block)
	setPositionOfBlockOnBoard(block)

func setActiveBlock(block : BoxHandler):
	active_block = block

func removeActiveBlock(block : BoxHandler):
	active_block = null

func spawnBlockAtPosition(pos : Vector2i, color : int):
	var newBlock : BoxHandler = block_node.instantiate()
	newBlock.bPosition = pos
	newBlock._set_color(color)
	newBlock.placed = true
	newBlock.levelGrid = self
	blocks[newBlock.bPosition.y][newBlock.bPosition.x] = newBlock
	levelManager.fallTimer.timeout.connect(newBlock._onFallTick)
	setPositionOfBlockOnBoard(newBlock)

func setPositionOfBlockOnBoard(block : BoxHandler):
	block.position = Vector2(block.bPosition.x*grid_space, -block.bPosition.y*grid_space)

func moveBlockDown(block : BoxHandler):
	if (block.bPosition.y - 1) < 0:
		place_block(block)
		return
	if blocks[block.bPosition.y-1][block.bPosition.x] != null:
		if blockCheck(blocks[block.bPosition.y][block.bPosition.x], blocks[block.bPosition.y-1][block.bPosition.x]):
			mergeBlocks(blocks[block.bPosition.y][block.bPosition.x], blocks[block.bPosition.y-1][block.bPosition.x])
		else:
			place_block(block)
		return
	#move Block Downwards
	blocks[block.bPosition.y][block.bPosition.x] = null
	block.bPosition.y -= 1
	blocks[block.bPosition.y][block.bPosition.x] = block
	setPositionOfBlockOnBoard(block)

func moveBlockLeft(block : BoxHandler):
	if (block.bPosition.x - 1) < 0:
		return
	if blocks[block.bPosition.y][block.bPosition.x-1] != null:
		return
	#move Block Downwards
	blocks[block.bPosition.y][block.bPosition.x] = null
	block.bPosition.x -= 1
	blocks[block.bPosition.y][block.bPosition.x] = block
	setPositionOfBlockOnBoard(block)
	
func moveBlockRight(block : BoxHandler):
	if (block.bPosition.x + 1) > grid_size.x-1:
		return
	if blocks[block.bPosition.y][block.bPosition.x+1] != null:
		return
	#move Block Downwards
	blocks[block.bPosition.y][block.bPosition.x] = null
	block.bPosition.x += 1
	blocks[block.bPosition.y][block.bPosition.x] = block
	setPositionOfBlockOnBoard(block)

func hardDropBlock(block : BoxHandler):
	var y = grid_size.y-1
	while(y >= 0):
		if y == 0:
			blocks[block.bPosition.y][block.bPosition.x] = null
			block.bPosition.y = y
			blocks[block.bPosition.y][block.bPosition.x] = block
			setPositionOfBlockOnBoard(block)
			place_block(block)
			return
		if blocks[y-1][block.bPosition.x] == null or blocks[y-1][block.bPosition.x].placed == false:
			y -= 1
		else:
			if blockCheck(blocks[block.bPosition.y][block.bPosition.x], blocks[y-1][block.bPosition.x]):
				mergeBlocks(blocks[block.bPosition.y][block.bPosition.x], blocks[y-1][block.bPosition.x])
				return
			else:
				blocks[block.bPosition.y][block.bPosition.x] = null
				block.bPosition.y = y
				blocks[block.bPosition.y][block.bPosition.x] = block
				setPositionOfBlockOnBoard(block)
				place_block(block)
				return
	
	
func place_block(block : BoxHandler):
	block.placed = true
	next_block()

func next_block():
	active_block = null
	levelManager.spawnBlock()

func mergeBlocks(upBlock : BoxHandler, downBlock : BoxHandler):
	if upBlock.bColor != downBlock.bColor:
		return
	downBlock.blockValue += upBlock.blockValue
	downBlock._updateBoxText()
	blocks[upBlock.bPosition.y][upBlock.bPosition.x] = null
	upBlock.queue_free()
	next_block()

func blockCheck(upBlock : BoxHandler, downBlock : BoxHandler) -> bool: #works regardless of position
	if upBlock == downBlock:
		return false
	return upBlock.bColor == downBlock.bColor

func _input(event: InputEvent) -> void:
	if active_block == null:
		return
	if event.is_action_pressed("left"):
		moveBlockLeft(active_block)
	if event.is_action_pressed("right"):
		moveBlockRight(active_block)
	if event.is_action_pressed("up"):
		hardDropBlock(active_block)
	if event.is_action_pressed("down"):
		moveBlockDown(active_block)
