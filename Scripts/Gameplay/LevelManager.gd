extends Node2D
class_name LevelManager

# --- Block / Enemy scenes ---
var block_node = load("res://Scenes/GameObjects/box.tscn")
var arrow_node = load("res://Scenes/GameObjects/arrow.tscn")
var indestructable_node = load("res://Scenes/GameObjects/indestructable.tscn")

var static_enemy_node = load("res://Scenes/GameObjects/enemyStatic.tscn")
var floater_enemy_node = load("res://Scenes/GameObjects/enemyFloater.tscn")
var painter_enemy_node = load("res://Scenes/GameObjects/enemyPainter.tscn")

# --- Timing & grid ---
@export var fallSpeed: float = 1.25
var fallTimer: Timer

@export var boxFiller: BoxFiller
@export var boxGrid: LevelGrid

# --- Enemy spawn tracking ---
var blocks_placed: int = 0
@export var enemy_spawn_interval: int = 5 # configurable

# --- Player box management ---
var current_block: BoxHandler = null
var next_block: BoxHandler = null

func _ready() -> void:
	fallTimer = Timer.new()
	fallTimer.wait_time = fallSpeed
	fallTimer.autostart = true
	add_child(fallTimer)

	# start first playable block + next preview
	current_block = createBlock()
	boxFiller.fillBlock(current_block)

	next_block = createBlock()
	boxFiller.fillBlock(next_block)

func createBlock() -> BoxHandler:
	var id = randi_range(0, 4)
	var newBlock: BoxHandler
	if id < 4:
		newBlock = block_node.instantiate()
	else:
		newBlock = arrow_node.instantiate()

	newBlock.bPosition = Vector2i(boxGrid.grid_size.x / 2, boxGrid.grid_size.y - 1)
	return newBlock

func spawnBlock():
	# move next → current
	if next_block != null and is_instance_valid(next_block):
		current_block = next_block
	else:
		current_block = createBlock()
		boxFiller.fillBlock(current_block)

	# generate new next block
	next_block = createBlock()
	boxFiller.fillBlock(next_block)

	blocks_placed += 1

	# spawn enemy every X blocks
	if blocks_placed % enemy_spawn_interval == 0:
		spawnEnemy()

	# let all enemies react to player block placement
	for row in boxGrid.blocks:
		for cell in row:
			if cell != null and cell.bType == BoxHandler.BlockType.Enemy:
				if cell.has_method("on_player_block_placed"):
					cell.on_player_block_placed()

# --- Helper to find lowest free space in a column ---
func get_lowest_free_position(x: int) -> Vector2i:
	for y in range(0, boxGrid.grid_size.y):
		if boxGrid.blocks[y][x] == null:
			return Vector2i(x, y)
	return Vector2i(x, -1)

# --- Spawn enemy at random column ---
func spawnEnemy():
	# Choose enemy type: 0=Static, 1=Floater, 2=Painter
	var id = randi_range(0, 2)
	var enemy: BoxHandler = null

	# Try to find a free column up to 10 times
	var tries = 0
	var col = 0
	var pos: Vector2i
	while tries < 10:
		col = randi_range(0, boxGrid.grid_size.x - 1)
		pos = boxGrid.get_lowest_free_position(col)
		if pos.y != -1:
			break
		tries += 1

	if pos.y == -1:
		return # no free column available

	# Instantiate the correct enemy type
	match id:
		0:
			enemy = static_enemy_node.instantiate()
		1:
			enemy = floater_enemy_node.instantiate()
		2:
			enemy = painter_enemy_node.instantiate()

	# Assign enemy properties
	enemy.levelGrid = boxGrid
	enemy.bPosition = pos
	enemy.bType = BoxHandler.BlockType.Enemy
	enemy.placed = true

	# Add enemy to grid and scene
	boxGrid.blocks[pos.y][pos.x] = enemy
	boxGrid.setPositionOfBlockOnBoard(enemy)
	boxGrid.add_child(enemy)

	# If Painter enemy, start its movement/painting behavior
	if enemy is PainterEnemy:
		enemy.start_painting()  # Make sure PainterEnemy.gd has a start_painting() method
