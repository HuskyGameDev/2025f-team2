extends Node2D

class_name LevelManager

var block_node = load("res://Scenes/GameObjects/box.tscn")
var arrow_node = load("res://Scenes/GameObjects/arrow.tscn")
var indestructable_node = load("res://Scenes/GameObjects/indestructable.tscn")

@export var fallSpeed : float = 1.25
var fallTimer : Timer

@export var boxFiller : BoxFiller
@export var boxGrid : LevelGrid
@export var levelOrder : PlacementOrder

var bid = 0 #block pos
var cid = 0 #color pos

func _ready() -> void:
	if levelOrder == null:
		push_error("Level Order is null! Add Level Order!")
	#get starting block
	bid = randi_range(0, 2147483647)
	bid %= len(levelOrder.typeOrder)
	#get starting color
	cid = randi_range(0, 2147483647)
	cid %= len(levelOrder.colorOrder)
	
	fallTimer = Timer.new()
	fallTimer.wait_time = fallSpeed
	fallTimer.autostart = true
	add_child(fallTimer)
	spawnBlock()

func createBlock() -> BoxHandler:
	#next block
	bid += 1
	if bid >= len(levelOrder.typeOrder):
		bid = 0
	#next Color
	cid += 1
	if cid >= len(levelOrder.colorOrder):
		cid = 0
	print("box " + str(levelOrder.typeOrder[bid]) + " color " + str(levelOrder.colorOrder[cid]))
	var newBlock : BoxHandler = getBlock()
	newBlock._set_color(levelOrder.colorOrder[cid])
	
	newBlock.bPosition = Vector2i(boxGrid.grid_size.x/2, boxGrid.grid_size.y-1)
	return newBlock

func getBlock() -> BoxHandler:
	var newBlock : BoxHandler
	if levelOrder.typeOrder[bid] == 0:
		newBlock = block_node.instantiate()
	elif levelOrder.typeOrder[bid] == 1:
		newBlock = arrow_node.instantiate()
	elif levelOrder.typeOrder[bid] == 2:
		newBlock = indestructable_node.instantiate()
	return newBlock

func spawnBlock():
	boxFiller.fillBlock(createBlock())
