extends Node2D

class_name LevelGrid

var block_node = load("res://Scenes/GameObjects/box.tscn")

@export var levelManager : LevelManager 

@export var grid_space : int
@export var grid_size : Vector2i

var active_block : BoxHandler

var blocks = []

var can_input : bool = true

func _ready() -> void:
	for i in grid_size.y:
		blocks.append([])
		for j in grid_size.x:
			blocks[i].append(null) # Set a starter value for each position

func addBlock(block : BoxHandler):
	block.levelGrid = self
	block.onAdd()
	block.get_parent().remove_child(block)
	add_child(block)
	blocks[block.bPosition.y][block.bPosition.x] = block
	levelManager.fallTimer.timeout.connect(block._onFallTick)
	if block.bType != BoxHandler.BlockType.Arrow:
		setActiveBlock(block)
	setPositionOfBlockOnBoard(block)

func removeBlock(block : BoxHandler):
	blocks[block.bPosition.y][block.bPosition.x] = null
	block.queue_free()

func setActiveBlock(block : BoxHandler):
	active_block = block

func removeActiveBlock():
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

func moveBlockDown(block : BoxHandler, control : bool = true):
	block.moveDown(control)

func moveBlockLeft(block : BoxHandler, merge : bool = false):
	block.moveLeft(merge)
	
func moveBlockRight(block : BoxHandler ,merge : bool = false):
	block.moveRight(merge)

func hardDropBlock(block : BoxHandler):
	block.hardDrop()

func explode(block : BoxHandler):
	removeBlock(block)
	if check_if_block_exist(blocks[block.bPosition.y-1][block.bPosition.x]):
		explode(blocks[block.bPosition.y-1][block.bPosition.x])
	if check_if_block_exist(blocks[block.bPosition.y+1][block.bPosition.x]):
		explode(blocks[block.bPosition.y+1][block.bPosition.x])
	if check_if_block_exist(blocks[block.bPosition.y][block.bPosition.x-1]):
		explode(blocks[block.bPosition.y][block.bPosition.x-1])
	if check_if_block_exist(blocks[block.bPosition.y][block.bPosition.x+1]):
		explode(blocks[block.bPosition.y][block.bPosition.x+1])

func place_block(block : BoxHandler):
	if block == active_block:
		block.placeBlock()

func next_block():
	removeActiveBlock()
	await get_tree().create_timer(.5).timeout
	levelManager.spawnBlock()

func mergeBlocks(upBlock : BoxHandler, downBlock : BoxHandler):
	if downBlock.bType != BoxHandler.BlockType.Block:
		return
	if upBlock.bColor != downBlock.bColor:
		return
	if upBlock == downBlock:
		return 
	upBlock.mergeBox(downBlock)

func blockCheck(upBlock : BoxHandler, downBlock : BoxHandler) -> bool: #works regardless of position
	if upBlock == null or downBlock == null:
		return false
	if upBlock == downBlock:
		return false
	return upBlock.bColor == downBlock.bColor

func get_all_blocks_in_board(flip = false) -> Array[BoxHandler]:
	var vaildBlocks : Array[BoxHandler]
	var currentPos = blocks.duplicate(true)
	for i in grid_size.y:
		if flip:
			currentPos[i].reverse()
		for j in grid_size.x:
			if currentPos[i][j] != null:
				if currentPos[i][j].bType != BoxHandler.BlockType.Arrow:
					vaildBlocks.append(currentPos[i][j])
	return vaildBlocks

func move_all_blocks_left():
	var vaildBlocks : Array[BoxHandler] = get_all_blocks_in_board()
	for block in vaildBlocks:
		moveBlockLeft(block, true)

func move_all_blocks_right():
	var vaildBlocks : Array[BoxHandler] = get_all_blocks_in_board(true)
	for block in vaildBlocks:
		moveBlockRight(block, true)

func disable_input():
	if !can_input:
		return
	can_input = false
	await get_tree().create_timer(0.05, false).timeout
	can_input = true
	

func _input(event: InputEvent) -> void:
	if !can_input:
		return
	if active_block == null:
		return
	if event.is_action_pressed("left", false):
		if !can_input:
			return
		moveBlockLeft(active_block)
		disable_input()
	if event.is_action_pressed("right", false):
		if !can_input:
			return
		moveBlockRight(active_block)
		disable_input()
	if event.is_action_pressed("up", false):
		if !can_input:
			return
		hardDropBlock(active_block)
		disable_input()
	if event.is_action_pressed("down", false):
		if !can_input:
			return
		moveBlockDown(active_block)
		disable_input()

func check_if_block_exist(block:BoxHandler) -> bool:
	if block == null:
		return false
	return true
