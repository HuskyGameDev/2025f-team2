extends Node2D

class_name BoxFiller

@export var levelGrid : LevelGrid

var fblock : BoxHandler

func fillBlock(block : BoxHandler):
	var bok = fblock
	if fblock != null:
		fblock.queue_free()
	add_child(block)
	block.position = Vector2(0,0)
	fblock = block
	block._set_color(randi_range(0,2))
	var time = 0.75
	while (fblock != null):
		if fblock.blockValue >= 20:
			break
			return
		if bok != fblock and bok != null:
			return
		if fblock.bType == fblock.BlockType.Block:
			var cts : Crystal = spawnCrystal()
			cts.on_die.connect(addToFBlock.bind(cts))
			cts.material = fblock.material
			cts.block = self
			await get_tree().create_timer(time, false).timeout
			if time > 0.25 and time < 5.0:
				time *= 1.075
		else:
			break
			return

func _input(event: InputEvent) -> void:
	if fblock == null:
		return
	if event.is_action_pressed("release"):
		levelGrid.addBlock(fblock)
		fblock = null

func spawnCrystal() -> Crystal:
	var crys = load("res://Scenes/GameObjects/crystals.tscn").instantiate()
	add_child(crys)
	crys.position.y = -140
	return crys
	
func addToFBlock(Cys : Crystal):
	if fblock != null:
		if fblock.material == Cys.material:
			fblock._addToBlock()
