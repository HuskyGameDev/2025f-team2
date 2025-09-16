extends Node2D

class_name BoxFiller

@export var levelGrid : LevelGrid

var fblock : BoxHandler

func fillBlock(block : BoxHandler):
	add_child(block)
	block.position = Vector2(0,0)
	fblock = block
	block._set_color(randi_range(0,1))
	

func _input(event: InputEvent) -> void:
	if fblock == null:
		return
	if event.is_action_pressed("release"):
		levelGrid.addBlock(fblock)
		fblock = null
	if event.is_action_pressed("ui_text_submit"):
		fblock._addToBlock()
