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

func spawnBlock():
	var new_block = createBlock()
	boxFiller.fillBlock(new_block)

	blocks_placed_since_enemy += 1
	if blocks_placed_since_enemy >= randi_range(3, 5):
		spawnRandomEnemy()
		blocks_placed_since_enemy = 0

func spawnRandomEnemy():
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
	enemy.levelGrid = boxGrid
	enemy.palletes = boxGrid.block_node.instantiate().palletes  # just grab palette for coloring

	add_child(enemy)

	# Spawn somewhere in the grid — no fancy height logic yet
	var spawn_col = randi_range(0, boxGrid.grid_size.x - 1)
	var spawn_row = randi_range(0, boxGrid.grid_size.y - 1)

	enemy.spawn_in_grid(boxGrid, Vector2i(spawn_col, spawn_row))
	boxGrid.setPositionOfBlockOnBoard(enemy)  # ensure sprite matches grid
