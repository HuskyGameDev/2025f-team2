extends Node2D

class_name LevelManager

var block_node = load("res://Scenes/GameObjects/box.tscn")

var arrow_node = load("res://Scenes/GameObjects/arrow.tscn")

var indestructable_node = load("res://Scenes/GameObjects/indestructable.tscn")

@export var fallSpeed : float = 1.25
var fallTimer : Timer

@export var boxFiller : BoxFiller
@export var boxGrid : LevelGrid

func _ready() -> void:
	fallTimer = Timer.new()
	fallTimer.wait_time = fallSpeed
	fallTimer.autostart = true
	add_child(fallTimer)
	spawnBlock()

func createBlock() -> BoxHandler:
	var id = randi_range(0, 4)
	var newBlock : BoxHandler
	##if id > 2:
		##newBlock = arrow_node.instantiate()
	##if id <= 2:
		##newBlock = indestructable_node.instantiate()
	if id < 4:
		newBlock = block_node.instantiate()
	elif id == 4:
		newBlock = arrow_node.instantiate()
	newBlock.bPosition = Vector2i(boxGrid.grid_size.x/2, boxGrid.grid_size.y-1)
	return newBlock
	

func spawnBlock():
	boxFiller.fillBlock(createBlock())
