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

func place_block(block : BoxHandler):
	block.placeBlock()

func next_block():
	removeActiveBlock()
	await get_tree().create_timer(.5).timeout
	levelManager.spawnBlock()

func mergeBlocks(upBlock : BoxHandler, downBlock : BoxHandler):
	if upBlock.bColor != downBlock.bColor:
		return
	upBlock.mergeBox(downBlock)

func blockCheck(upBlock : BoxHandler, downBlock : BoxHandler) -> bool: #works regardless of position
	if upBlock == downBlock:
		return false
	return upBlock.bColor == downBlock.bColor

func get_all_blocks_in_board() -> Array:
	var vaildBlocks = []
	for i in grid_size.y:
		for j in grid_size.x:
			if blocks[i][j] != null:
				vaildBlocks.append(blocks[i][j])
	return vaildBlocks

func move_all_blocks_left():
	var vaildBlocks = get_all_blocks_in_board()
	for block in vaildBlocks:
		moveBlockLeft(block, true)
		moveBlockDown(block, false)
		

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
	if event.is_action_pressed("ui_text_indent"):
		move_all_blocks_left()
