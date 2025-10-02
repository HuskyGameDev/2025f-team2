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
@export var fallSpeed : float = 1.25
var fallTimer : Timer

@export var boxFiller : BoxFiller
@export var boxGrid : LevelGrid

# --- Enemy spawn tracking ---
var blocks_placed: int = 0
@export var enemy_spawn_interval: int = 5 # configurable

func _ready() -> void:
	fallTimer = Timer.new()
	fallTimer.wait_time = fallSpeed
	fallTimer.autostart = true
	add_child(fallTimer)
	spawnBlock()

# --- Create normal blocks ---
func createBlock() -> BoxHandler:
	var id = randi_range(0, 4)
	var newBlock : BoxHandler
	if id < 4:
		newBlock = block_node.instantiate()
	elif id == 4:
		newBlock = arrow_node.instantiate()
	newBlock.bPosition = Vector2i(boxGrid.grid_size.x/2, boxGrid.grid_size.y-1)
	return newBlock

# --- Spawn a new player block ---
func spawnBlock():
	var block = createBlock()
	boxFiller.fillBlock(block)
	blocks_placed += 1

	# Spawn enemy every X blocks
	if blocks_placed % enemy_spawn_interval == 0:
		spawnEnemy()

	# Let all enemies react to player block placement
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
	return Vector2i(x, -1) # column full

func spawnEnemy():
	var id = randi_range(0, 2) # 0=Static, 1=Floater, 2=Painter
	var enemy: BoxHandler
	var col = randi_range(0, boxGrid.grid_size.x - 1)
	var pos: Vector2i

	match id:
		0: # --- Static Enemy ---
			enemy = static_enemy_node.instantiate()
			pos = boxGrid.get_lowest_free_position(col)
			if pos.y == -1: return # column full

		1: # --- Floater Enemy ---
			enemy = floater_enemy_node.instantiate()
			pos = Vector2i(col, boxGrid.grid_size.y - 2) # second-to-top row

		2: # --- Painter Enemy ---
			enemy = painter_enemy_node.instantiate()
			pos = boxGrid.get_lowest_free_position(col)
			if pos.y == -1: return # column full

	# Register enemy in grid
	enemy.levelGrid = boxGrid       # assign grid
	enemy.bPosition = pos
	enemy.bType = BoxHandler.BlockType.Enemy
	enemy.placed = true             # enemies are "placed"
	boxGrid.blocks[pos.y][pos.x] = enemy
	boxGrid.setPositionOfBlockOnBoard(enemy)
	add_child(enemy)
