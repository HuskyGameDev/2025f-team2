extends BoxHandler

var side = "left"

func _init() -> void:
	bType = BlockType.Arrow

func _ready() -> void:
	super._ready()
	var sided = randi_range(0,1)
	if sided == 0:
		side = "left"
		flip_h = false
	elif sided == 1:
		side = "right"
		flip_h = true

func _updateBoxText():
	$Label.text = ""

func moveLeft(merge : bool = false):
	return

func moveRight(merge : bool = false):
	return

func mergeBox(downBlock:BoxHandler):
	return

func placeBlock():
	return

func _addToBlock():
	return

func moveNext():
	placed = true
	z_index = 255
	if side == "left":
		levelGrid.move_all_blocks_left()
	elif side == "right":
		levelGrid.move_all_blocks_right()
	var s_tween = create_tween().tween_property(self, "scale", Vector2(50, 50), 0.9).set_trans(Tween.TRANS_QUINT)
	create_tween().tween_property(self, "modulate:a", 0.0, 0.9).set_trans(Tween.TRANS_QUINT)
	await get_tree().create_timer(0.5,false).timeout
	levelGrid.next_block()
	await get_tree().create_timer(0.5,false).timeout
	queue_free()


func moveDown(control : bool = true):
	return

func onAdd():
	floating = false
	moveNext()
