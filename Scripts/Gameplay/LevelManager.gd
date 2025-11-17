extends Node2D
class_name LevelManager

enum LoseType{None, time, blockLose, tooManyBombs, tooManyEnemies, scoreONBoard}

@export var fallSpeed: float = 1.25
var fallTimer: Timer

@export var boxFiller: BoxFiller
@export var boxGrid: LevelGrid
@export var currentLevelState : LevelState
@export var winlosescreen: WinLose
@export var magicSquareUI : MagicSquareUI
@export var winningMagicSquareUI : MagicSquareUI

#disable spawning for tutorial
@export var spawnBlocks = true
var enemiesAllowed = true

var bid = 0
var cid = 0

var blocks_placed_since_enemy = 0
var last_enemy_type = -1


var winConditionPresent = false
@export var listWins: Label
var winConString: String = "Win conditions: \n"
@export var listLoses: Label
var loseConString: String = "Lose conditions: \n"

#track how many enemies killed
var enemiesKilled = 0
#track score
var score = 0
var score_indicator = preload("res://Scenes/GameObjects/Score_Indicator.tscn")
#track score
var removedBlocks = 0
#lose timer, setup in setupLevel
var loseTimer: Timer
#for purposes of counting placed blocks, we will use the spawning of a block to measure
var blocksUsed = 0
#for purposes of counting bombs used, any bomb that goes off is counted
var bombsBlown = 0
#the amount of enemies on the board
var enemiesAlive = 0
#the score on board is always the value of all blocks in the board
var scoreOnBoard = 0

var lastChance = false
var loseCondition : LoseType = LoseType.None
var lastTimer = 0.5
var chanceTime = 2


#update for the win and lose conditions
func _process(delta: float) -> void:
	
	if(currentLevelState.wlconditions != null && (currentLevelState.wlconditions.scoreOnBoardLoseCondition || currentLevelState.wlconditions.scoreOnBoardWinCondition) ):
		scoreOnBoard = 0
		var board = boxGrid.get_all_blocks_in_board()
		for block in board:
			if(block.bType == block.BlockType.Enemy):
				continue
			if(!block.placed):
				continue
			if(currentLevelState.wlconditions.scoreColorOnBoardWinCondition && block.bColor != currentLevelState.wlconditions.targetColor):
				continue
			scoreOnBoard += block.blockValue
	
	if(currentLevelState.wlconditions != null):
		winConString = "\n"
		var winConExists: bool = false
		#only show if not beaten
		if(currentLevelState.wlconditions.killEnemiesCondition && currentLevelState.wlconditions.killEnemies > enemiesKilled):
			#winConString += "Kill enemies: " + str(currentLevelState.wlconditions.killEnemies-enemiesKilled) + "\n"
			winningMagicSquareUI.setUI(0, 3, currentLevelState.wlconditions.killEnemies-enemiesKilled)
			winConExists = true
			winConditionPresent = true
		if(currentLevelState.wlconditions.achieveScoreCondition && currentLevelState.wlconditions.targetScore > score):
			winningMagicSquareUI.setUI(1, 4, currentLevelState.wlconditions.targetScore-score)
			#winConString += "Achieve score: " + str(currentLevelState.wlconditions.targetScore-score) + "\n"
			winConExists = true
			winConditionPresent = true
		if(currentLevelState.wlconditions.removeBlocksCondition && currentLevelState.wlconditions.targetRemovedBlocks > removedBlocks):
			winningMagicSquareUI.setUI(2, 6, currentLevelState.wlconditions.targetRemovedBlocks - removedBlocks)
			#winConString += "Remove blocks: " + str(currentLevelState.wlconditions.targetRemovedBlocks - removedBlocks) + "\n"
			winConExists = true
			winConditionPresent = true
		if(currentLevelState.wlconditions.scoreOnBoardWinCondition && currentLevelState.wlconditions.scoreOnBoardTarget > scoreOnBoard):
			if(!currentLevelState.wlconditions.scoreColorOnBoardWinCondition):
				winningMagicSquareUI.setUI(3, 7, currentLevelState.wlconditions.scoreOnBoardTarget - scoreOnBoard)
				#winConString += "score on board: " + str(currentLevelState.wlconditions.scoreOnBoardTarget - scoreOnBoard) + "\n"
			else:
				winningMagicSquareUI.places[3].material = load("res://Materials/Palletes/GreenBox.tres")
				winningMagicSquareUI.setUI(3, 8, currentLevelState.wlconditions.scoreOnBoardTarget - scoreOnBoard)
				#winConString += "color " + str(currentLevelState.wlconditions.targetColor) +  " score: " + str(currentLevelState.wlconditions.scoreOnBoardTarget - scoreOnBoard) + "\n"
			winConExists = true
			winConditionPresent = true
		if(!winConExists):
			winConString += "empty"
		listWins.text = winConString
		
	if(currentLevelState.wlconditions):
		if lastChance:
			lastTimer -= delta
		if lastChance:
			loseConString = "Last Chance " + "%.2f" % [lastTimer] + "\n"
			
		var loseConExists: bool = false
		
		if(currentLevelState.wlconditions.timerLoseCondition && loseTimer != null):
			magicSquareUI.clockOn()
			magicSquareUI.set_Clock_UI(loseTimer.time_left)
			loseConExists = true
			
		if(currentLevelState.wlconditions.blockLoseCondition && blocksUsed < currentLevelState.wlconditions.blockLossLimit):
			magicSquareUI.setUI(0, 5, currentLevelState.wlconditions.blockLossLimit-blocksUsed)
			#loseConString += "Blocks left: " + str(currentLevelState.wlconditions.blockLossLimit-blocksUsed ) + "\n"
			loseConExists = true
			if loseCondition == LoseType.blockLose:
				loseCondition = LoseType.None
				lastChance = false
				lastTimer = chanceTime
		elif(currentLevelState.wlconditions.blockLoseCondition && currentLevelState.wlconditions.blockLossLimit <= blocksUsed):
			magicSquareUI.setUI(0, 5, currentLevelState.wlconditions.blockLossLimit-blocksUsed)
			loseCondition = LoseType.blockLose
			loss()
			
		if(currentLevelState.wlconditions.tooManyBombsCondition && currentLevelState.wlconditions.bombLimit > bombsBlown):
			magicSquareUI.setUI(1, 1, currentLevelState.wlconditions.bombLimit-bombsBlown)
			#loseConString += "Bombs: " + str(currentLevelState.wlconditions.bombLimit-bombsBlown) + "\n"
			loseConExists = true
			if loseCondition == LoseType.tooManyBombs:
				loseCondition = LoseType.None
				lastChance = false
				lastTimer = chanceTime
		elif(currentLevelState.wlconditions.tooManyBombsCondition && currentLevelState.wlconditions.bombLimit <= bombsBlown):
			magicSquareUI.setUI(1, 1, currentLevelState.wlconditions.bombLimit-bombsBlown)
			loseCondition = LoseType.tooManyBombs
			loss()
		
		if(currentLevelState.wlconditions.tooManyEnemiesCondition && currentLevelState.wlconditions.enemyLimit > enemiesAlive):
			magicSquareUI.setUI(2, 0, currentLevelState.wlconditions.enemyLimit-enemiesAlive)
			#loseConString += "Enemies: " + str(currentLevelState.wlconditions.enemyLimit-enemiesAlive) + "\n"
			loseConExists = true
			if loseCondition == LoseType.tooManyEnemies:
				loseCondition = LoseType.None
				lastChance = false
				lastTimer = chanceTime
		elif(currentLevelState.wlconditions.tooManyEnemiesCondition && currentLevelState.wlconditions.enemyLimit <= enemiesAlive):
			magicSquareUI.setUI(2, 0, currentLevelState.wlconditions.enemyLimit-enemiesAlive)
			loseCondition = LoseType.tooManyEnemies
			loss()
			
		if(currentLevelState.wlconditions.scoreOnBoardLoseCondition && currentLevelState.wlconditions.scoreOnBoardLimit > scoreOnBoard):
			magicSquareUI.setUI(3, 2, currentLevelState.wlconditions.scoreOnBoardLimit - scoreOnBoard)
			#loseConString += "Score on board: " + str(currentLevelState.wlconditions.scoreOnBoardLimit - scoreOnBoard) + "\n"
			loseConExists = true
			if loseCondition == LoseType.scoreONBoard:
				loseCondition = LoseType.None
				lastChance = false
				lastTimer = chanceTime
		elif(currentLevelState.wlconditions.scoreOnBoardLoseCondition && currentLevelState.wlconditions.scoreOnBoardLimit <= scoreOnBoard):
			magicSquareUI.setUI(3, 2, currentLevelState.wlconditions.scoreOnBoardLimit - scoreOnBoard)
			loseCondition = LoseType.scoreONBoard
			loss()
		listLoses.text = loseConString

func conditonCheck():
	if(currentLevelState.wlconditions):
		checkConditions()

func checkConditions():
	var win = true

	if(currentLevelState.wlconditions.killEnemiesCondition && currentLevelState.wlconditions.killEnemies > enemiesKilled):
		win = false
	
	if(currentLevelState.wlconditions.achieveScoreCondition && currentLevelState.wlconditions.targetScore > score):
		win = false
		
	if(currentLevelState.wlconditions.removeBlocksCondition && currentLevelState.wlconditions.targetRemovedBlocks > removedBlocks):
		win = false
		
	if(currentLevelState.wlconditions.scoreOnBoardWinCondition && currentLevelState.wlconditions.scoreOnBoardTarget > scoreOnBoard):
		win = false
		
	if(win):
		winlosescreen.winGame()


func loss():
	if lastChance == true:
		if lastTimer > 0:
			return
	if(winlosescreen != null):
		if lastChance == false:
			lastChance = true
			return
		if loseCondition != LoseType.None:
			winlosescreen.loseGame()

func forceLoss():
	winlosescreen.loseGame()

func add_score(value: int, block: BoxHandler, isMerge = false):
	#multiplier rewards players for placing and using bigger blocks
	var multiplier = 1.0
	if(value < 10):
		multiplier = 1
	elif(value >= 10 || value < 15):
		multiplier = 1.5
	elif(value >= 15):
		multiplier = 2.0
	if(isMerge):
		multiplier += 0.25
	score += value * multiplier
	print("instantiate")
	var scoreText = score_indicator.instantiate()
	scoreText.position = block.global_position
	scoreText.scoreText = "+" + str(value * multiplier) + " x%.1f" % [multiplier]
	add_child(scoreText)

func _create_background(index:int):
	match index:
		0:
			var bg = GlobalNodeLoader.clouds.instantiate()
			add_child(bg)

func _ready() -> void:
	if magicSquareUI == null:
		push_error("No Magic Square!")
	if winningMagicSquareUI == null:
		push_error("No Winning Magic Square!")
	lastTimer = chanceTime
	fallTimer = Timer.new()
	fallTimer.wait_time = fallSpeed
	fallTimer.autostart = true
	fallTimer.timeout.connect(conditonCheck)
	add_child(fallTimer)

func setLevelState(ste : LevelState):
	currentLevelState = ste
	setupLevel()

func setupLevel():
	if currentLevelState == null:
		push_error("No level state found! Aborting...")
		return
	_create_background(currentLevelState.background)
	if currentLevelState.wlconditions == null:
		push_error("No win loss conditions!")
	if currentLevelState.levelOrder == null:
		push_error("Level Order is null!")
	# safe guard
	if boxGrid == null:
		push_error("LevelManager: boxGrid not assigned!")
	
	bid = randi_range(0, 2147483647) % len(currentLevelState.levelOrder.typeOrder)
	cid = randi_range(0, 2147483647) % len(currentLevelState.levelOrder.colorOrder)

	#sets the lose timer if that condition is active
	if(currentLevelState.wlconditions.timerLoseCondition):
		loseTimer = Timer.new()
		loseTimer.one_shot = true
		loseTimer.wait_time = currentLevelState.wlconditions.timeTillLoss
		loseTimer.timeout.connect(forceLoss)
		add_child(loseTimer)
		loseTimer.start()

	#if spawnBlocks is false, it won't automatically spawn a block
	if(spawnBlocks):
		spawnBlock()
	
	createLevel(currentLevelState.blockOrder)


func createBlock() -> BoxHandler:
	bid += 1
	if bid >= len(currentLevelState.levelOrder.typeOrder):
		bid = 0
	cid += 1
	if cid >= len(currentLevelState.levelOrder.colorOrder):
		cid = 0

	var newBlock: BoxHandler = getBlock()
	newBlock._set_color(currentLevelState.levelOrder.colorOrder[cid])
	newBlock.bPosition = Vector2i(boxGrid.grid_size.x / 2, boxGrid.grid_size.y - 1)
	newBlock.levelGrid = boxGrid
	return newBlock

func getBlock() -> BoxHandler:
	match currentLevelState.levelOrder.typeOrder[bid]:
		0: return GlobalNodeLoader.block_node.instantiate()
		1: return GlobalNodeLoader.arrow_node.instantiate()
		2: return GlobalNodeLoader.indestructable_node.instantiate()
	return GlobalNodeLoader.block_node.instantiate()

func getSpeficBlock(type:int) -> BoxHandler:
	match type:
		0: return GlobalNodeLoader.block_node.instantiate()
		1: return GlobalNodeLoader.arrow_node.instantiate()
		2: return GlobalNodeLoader.indestructable_node.instantiate()
	return GlobalNodeLoader.block_node.instantiate()
	
#autoSpawn will be true automatically for all ways of spawning, 
#makes it able to be manually spawned whilst spawnBlocks is false
func spawnBlock(autoSpawn = true) -> BoxHandler:
	if(!spawnBlocks && autoSpawn):
		return
	var new_block = createBlock()
	boxFiller.fillBlock(new_block)
	
	#send in ref to this script
	new_block.lvlMngr = self

	blocks_placed_since_enemy += 1
	if enemiesAllowed:
		#assumes enemyStats is formatted correctly
		if blocks_placed_since_enemy >= randi_range(currentLevelState.enemyStats.enemyPerBlock.x, currentLevelState.enemyStats.enemyPerBlock.y):
			spawnRandomEnemy()
			blocks_placed_since_enemy = 0
	return new_block
	
#may help later, I just need to spawn an arrow specifically in the tutorial
#must use this signature: levelmngr.spawnSpecificBlock(levelmngr.blank_node) replace blank with correct node
func spawnSpecificBlock(node) -> BoxHandler:
	var new_block = node.instantiate()
	boxFiller.fillBlock(new_block)
	new_block._set_color(currentLevelState.levelOrder.colorOrder[cid])
	new_block.bPosition = Vector2i(boxGrid.grid_size.x / 2, boxGrid.grid_size.y - 1)
	new_block.levelGrid = boxGrid
	return new_block

func spawnBlockAtPosition(type, bposition:Vector2i, color, value : int):
	var new_block = getSpeficBlock(type)
	new_block.lvlMngr = self
	if(color == Block.BlockColor.Random):
		color = randi() % len(BoxHandler.BlockColor)
		print(color)
	new_block._set_color(color)
	new_block.bPosition = bposition
	new_block.levelGrid = boxGrid
	new_block.blockValue = value
	boxGrid.addBlock(new_block, false)
	await get_tree().process_frame
	new_block.placed = true
	new_block.prePlaced = true

func spawnEnemyAtPosition(type, bposition:Vector2i, color, health):
	var enemy_scene: PackedScene = get_enemy_scene(type)
	var enemy: EnemyHandler = enemy_scene.instantiate()
	if enemy == null:
		push_error("Failed to instantiate enemy scene.")
		return
	#send in ref to this script
	enemy.lvlMngr = self
	#send in the enemy stats variable
	enemy.enemyStats = currentLevelState.enemyStats
	enemy.preplaced = true
	enemy.health = health
	# Add enemy to the grid
	boxGrid.add_child(enemy)

	# Spawn into grid
	enemiesAlive += 1
	if(color == Block.BlockColor.Random):
		color = randi() % len(BoxHandler.BlockColor)
		print(color)
	enemy.spawn_in_grid(boxGrid, bposition, color)

func createLevel(order : BlockOrder):
	var pos : Vector2i
	while pos.y <= len(order.levelOrder)-1:
		while pos.x <= len(order.levelOrder[pos.y].blocks)-1:
			var block : Block = order.levelOrder[pos.y].blocks[pos.x]
			if block != null:
				if block.blockType != block.BlockType.Enemy:
					spawnBlockAtPosition(translatedBlockType(block.blockType), pos, block.blockColor, block.value)
				else:
					spawnEnemyAtPosition(block.enemyType, pos, block.blockColor, block.value)
			pos.x += 1
		pos.x = 0
		pos.y += 1

func translatedBlockType(blockType) -> int:
	match blockType:
		Block.BlockType.Standard:
			return BoxHandler.BlockType.Block
		Block.BlockType.Indestructable:
			return BoxHandler.BlockType.Indestructible
	return BoxHandler.BlockType.Block

func spawnRandomEnemy():
	print("Attempted enemy spawn")
	#I needed a way to not spawn enemies (tutorial)
	if currentLevelState.levelOrder.enemyTypeOrder[0] == "null":
		return
	

	var enemy_type = randi() % 3
	while enemy_type == last_enemy_type:
		enemy_type = randi() % 3
	last_enemy_type = enemy_type

	var enemy_scene: PackedScene = get_enemy_scene(enemy_type)

	var enemy: EnemyHandler = enemy_scene.instantiate()
	if enemy == null:
		push_error("Failed to instantiate enemy scene.")
		return
	
	#send in ref to this script
	enemy.lvlMngr = self
	#send in the enemy stats variable
	enemy.enemyStats = currentLevelState.enemyStats


	# Ensure palletes from boxGrid
	if boxGrid != null and boxGrid.block_node != null:
		var sample = boxGrid.block_node.instantiate()
		if sample != null and "palletes" in sample:
			enemy.palletes = sample.palletes
		if is_instance_valid(sample):
			sample.queue_free()

	# --- Determine spawn location ---
	var spawn_col = randi_range(0, boxGrid.grid_size.x - 1)
	var spawn_row = 0

	match enemy_type:
		0: # Static - spawn visually near bottom (numerically high y)
			for row in range(0, boxGrid.grid_size.y - 1):
				if boxGrid.blocks[row][spawn_col] == null:
					spawn_row = row
					break
		1: # Floater - spawn higher up
			var attempts = 0
			spawn_row = randi_range(0, int(boxGrid.grid_size.y * 0.4))
			while attempts < 30 and boxGrid.blocks[spawn_row][spawn_col] != null:
				spawn_col = randi_range(0, boxGrid.grid_size.x - 1)
				spawn_row = randi_range(0, int(boxGrid.grid_size.y * 0.4))
				attempts += 1
			spawn_row = clamp(spawn_row, 0, boxGrid.grid_size.y - 1)
		2: # Painter - also spawn visually near bottom
			for row in range(0, boxGrid.grid_size.y - 1):
				if boxGrid.blocks[row][spawn_col] == null:
					spawn_row = row
					break

	spawn_col = clamp(spawn_col, 0, boxGrid.grid_size.x - 1)
	spawn_row = clamp(spawn_row, 0, boxGrid.grid_size.y - 1)

	# --- Random color selection ---
	var color_index: int
	if enemy.palletes.size() > 0:
		color_index = randi_range(0, enemy.palletes.size() - 1)
	else:
		color_index = randi_range(0, 2)  # fallback: 0–2

	# Add enemy to the grid
	boxGrid.add_child(enemy)

	# Spawn into grid
	enemiesAlive += 1
	enemy.spawn_in_grid(boxGrid, Vector2i(spawn_col, spawn_row), color_index)

#Spawns a specific type of enemy
#must use this signature: levelmngr.spawnSpecificEnemy(x, y)
#x = 
#		0 static_enemy_node
#		1 floater_enemy_node
#		2 painter
#y = 
#	0 green
#	1 red
#	2 yellow
func spawnSpecificEnemy(enemy_type: int, color = -1) -> EnemyHandler:
	print("Attempted enemy spawn")
	
	var enemy_scene: PackedScene = get_enemy_scene(enemy_type)


	var enemy: EnemyHandler = enemy_scene.instantiate()
	if enemy == null:
		push_error("Failed to instantiate enemy scene.")
		return
		
	# --- Determine spawn location ---
	var spawn_col = randi_range(0, boxGrid.grid_size.x - 1)
	var spawn_row = 0

	match enemy_type:
		0: # Static - spawn visually near bottom (numerically high y)
			for row in range(0, boxGrid.grid_size.y - 1):
				if boxGrid.blocks[row][spawn_col] == null:
					spawn_row = row
					break
		1: # Floater - spawn higher up
			var attempts = 0
			spawn_row = randi_range(0, int(boxGrid.grid_size.y * 0.4))
			while attempts < 30 and boxGrid.blocks[spawn_row][spawn_col] != null:
				spawn_col = randi_range(0, boxGrid.grid_size.x - 1)
				spawn_row = randi_range(0, int(boxGrid.grid_size.y * 0.4))
				attempts += 1
			spawn_row = clamp(spawn_row, 0, boxGrid.grid_size.y - 1)
		2: # Painter - also spawn visually near bottom
			for row in range(0, boxGrid.grid_size.y - 1):
				if boxGrid.blocks[row][spawn_col] == null:
					spawn_row = row
					break

	spawn_col = clamp(spawn_col, 0, boxGrid.grid_size.x - 1)
	spawn_row = clamp(spawn_row, 0, boxGrid.grid_size.y - 1)

	# Add enemy to the grid
	boxGrid.add_child(enemy)

	# Spawn into grid
	enemy.spawn_in_grid(boxGrid, Vector2i(spawn_col, spawn_row), color)
	enemy.lvlMngr = self
	return enemy

func get_enemy_scene(enemy_type) -> PackedScene:
	var enemy_scene : PackedScene
	match enemy_type:
		0: enemy_scene = GlobalNodeLoader.static_enemy_node
		1: enemy_scene = GlobalNodeLoader.floater_enemy_node
		2: enemy_scene = GlobalNodeLoader.painter_enemy_node
	return enemy_scene
