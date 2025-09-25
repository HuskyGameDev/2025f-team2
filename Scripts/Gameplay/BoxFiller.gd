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
	var time = 1.0
	while (fblock != null):
		if fblock.blockValue >= 20:
			break
			return
		if bok != fblock and bok != null:
			return
		fblock._addToBlock()
		await get_tree().create_timer(time).timeout
		if time > 0.01:
			time /= 1.3

func _input(event: InputEvent) -> void:
	if fblock == null:
		return
	if event.is_action_pressed("release"):
		levelGrid.addBlock(fblock)
		fblock = null
