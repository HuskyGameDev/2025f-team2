extends Node2D

class_name LevelGrid

var block_node = load("res://Scenes/GameObjects/box.tscn")

@export var levelManager : LevelManager 
@export var ribbon : RibbonAnimator

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
	setActiveBlock(block)
	setPositionOfBlockOnBoard(block)

func removeBlock(block : BoxHandler):
	levelManager.removedBlocks += 1
	blocks[block.bPosition.y][block.bPosition.x] = null
	block.queue_free()

func setActiveBlock(block : BoxHandler):
	ribbon.setControl()
	active_block = block

func removeActiveBlock():
	ribbon.setIdle()
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
	levelManager.bombsBlown += 1
	removeBlock(block)
	if block.bPosition.y-1 >= 0:
		if is_instance_valid(blocks[block.bPosition.y-1][block.bPosition.x]):
			if check_if_block_exist(blocks[block.bPosition.y-1][block.bPosition.x]):
				removeBlock(blocks[block.bPosition.y-1][block.bPosition.x])
	if block.bPosition.y+1 < grid_size.y:
		if is_instance_valid(blocks[block.bPosition.y+1][block.bPosition.x]):
			if check_if_block_exist(blocks[block.bPosition.y+1][block.bPosition.x]):
				removeBlock(blocks[block.bPosition.y+1][block.bPosition.x])
	if block.bPosition.x-1 >= 0:
		if is_instance_valid(blocks[block.bPosition.y][block.bPosition.x-1]):
			if check_if_block_exist(blocks[block.bPosition.y][block.bPosition.x-1]):
				removeBlock(blocks[block.bPosition.y][block.bPosition.x-1])
	if block.bPosition.x+1 < grid_size.x:
		if is_instance_valid(blocks[block.bPosition.y][block.bPosition.x+1]):
			if check_if_block_exist(blocks[block.bPosition.y][block.bPosition.x+1]):
				removeBlock(blocks[block.bPosition.y][block.bPosition.x+1])

func place_block(block : BoxHandler):
	if block == active_block:
		block.placeBlock()

func next_block(calledFrom: BoxHandler = null):
	if calledFrom == null || calledFrom == active_block:
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
		
func move_row_blocks_left(arrowThatCalled: BoxHandler):
	var vaildBlocks : Array[BoxHandler] = get_all_blocks_in_board()
	for block in vaildBlocks:
		if(block.bPosition.y == arrowThatCalled.bPosition.y):
			moveBlockLeft(block, true)

func move_row_blocks_right(arrowThatCalled: BoxHandler):
	var vaildBlocks : Array[BoxHandler] = get_all_blocks_in_board(true)
	for block in vaildBlocks:
		if(block.bPosition.y == arrowThatCalled.bPosition.y):
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
	if event.is_action_pressed("release", false):
		#go into freefall
		if(active_block.bType == BoxHandler.BlockType.Block):
			next_block()
			return
		if(active_block.bType == BoxHandler.BlockType.Arrow):
			active_block.moveRow()
			next_block()
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

func get_lowest_free_position(column: int) -> Vector2i:
	# Return the lowest available (empty) grid cell in a column.
	for row in range(grid_size.y - 1, -1, -1):  # start from bottom, go upward
		if blocks[row][column] == null:
			return Vector2i(column, row)

	# If the column is full, return topmost cell (to prevent null issues)
	return Vector2i(column, 0)


func check_if_block_exist(block:BoxHandler) -> bool:
	if block == null:
		return false
	return true

func damage_enemies_at(pos: Vector2i, color_index: int, amount: int = 1):
	if !has_node("Enemies"):
		return
	var enemies_node = get_node("Enemies")
	for e in enemies_node.get_children():
		if e is EnemyHandler and e.grid_pos == pos:
			e.take_damage(amount, color_index)
