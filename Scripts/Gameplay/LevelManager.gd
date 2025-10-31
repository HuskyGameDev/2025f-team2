extends Node2D
class_name LevelManager

# Block scenes
var block_node = load("res://Scenes/GameObjects/box.tscn")
var arrow_node = load("res://Scenes/GameObjects/arrow.tscn")
var indestructable_node = load("res://Scenes/GameObjects/indestructable.tscn")

# Enemy scenes
var static_enemy_node = load("res://Scenes/GameObjects/enemyStatic.tscn")
var floater_enemy_node = load("res://Scenes/GameObjects/enemyFloater.tscn")
var painter_enemy_node = load("res://Scenes/GameObjects/enemyPainter.tscn")

@export var fallSpeed: float = 1.25
var fallTimer: Timer

@export var boxFiller: BoxFiller
@export var boxGrid: LevelGrid
@export var levelOrder: PlacementOrder

#disable spawning for tutorial
@export var spawnBlocks = true

var bid = 0
var cid = 0

var blocks_placed_since_enemy = 0
var last_enemy_type = -1

func _ready() -> void:
	if levelOrder == null:
		push_error("Level Order is null!")
	# safe guard
	if boxGrid == null:
		push_error("LevelManager: boxGrid not assigned!")

	bid = randi_range(0, 2147483647) % len(levelOrder.typeOrder)
	cid = randi_range(0, 2147483647) % len(levelOrder.colorOrder)

	fallTimer = Timer.new()
	fallTimer.wait_time = fallSpeed
	fallTimer.autostart = true
	add_child(fallTimer)

	#if spawnBlocks is false, it won't automatically spawn a block
	if(spawnBlocks):
		spawnBlock()

func createBlock() -> BoxHandler:
	bid += 1
	if bid >= len(levelOrder.typeOrder):
		bid = 0
	cid += 1
	if cid >= len(levelOrder.colorOrder):
		cid = 0

	var newBlock: BoxHandler = getBlock()
	newBlock._set_color(levelOrder.colorOrder[cid])
	newBlock.bPosition = Vector2i(boxGrid.grid_size.x / 2, boxGrid.grid_size.y - 1)
	newBlock.levelGrid = boxGrid
	return newBlock

func getBlock() -> BoxHandler:
	match levelOrder.typeOrder[bid]:
		0: return block_node.instantiate()
		1: return arrow_node.instantiate()
		2: return indestructable_node.instantiate()
	return block_node.instantiate()

#autoSpawn will be true automatically for all ways of spawning, makes it able to be spawning
func spawnBlock(autoSpawn = true) -> BoxHandler:
	if(!spawnBlocks && autoSpawn):
		return
	var new_block = createBlock()
	boxFiller.fillBlock(new_block)

	blocks_placed_since_enemy += 1
	if blocks_placed_since_enemy >= randi_range(3, 5):
		spawnRandomEnemy()
		blocks_placed_since_enemy = 0
	return new_block
	
#may help later, I just need to spawn an arrow specifically in the tutorial
#must use this signature: levelmngr.spawnSpecificBlock(levelmngr.blank_node) replace blank with correct node
func spawnSpecificBlock(node) -> BoxHandler:
	var new_block = node.instantiate()
	boxFiller.fillBlock(new_block)
	new_block._set_color(levelOrder.colorOrder[cid])
	new_block.bPosition = Vector2i(boxGrid.grid_size.x / 2, boxGrid.grid_size.y - 1)
	new_block.levelGrid = boxGrid
	return new_block

func spawnRandomEnemy():
	print("Attempted enemy spawn")
	#I needed a way to not spawn enemies (tutorial)
	if levelOrder.enemyTypeOrder[0] == "null":
		return
	
	var enemy_scene: PackedScene
	var enemy_type = randi() % 3
	while enemy_type == last_enemy_type:
		enemy_type = randi() % 3
	last_enemy_type = enemy_type

	match enemy_type:
		0: enemy_scene = static_enemy_node
		1: enemy_scene = floater_enemy_node
		2: enemy_scene = painter_enemy_node

	var enemy: EnemyHandler = enemy_scene.instantiate()
	if enemy == null:
		push_error("Failed to instantiate enemy scene.")
		return

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
	
	var enemy_scene: PackedScene

	match enemy_type:
		0: enemy_scene = static_enemy_node
		1: enemy_scene = floater_enemy_node
		2: enemy_scene = painter_enemy_node

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
	return enemy
