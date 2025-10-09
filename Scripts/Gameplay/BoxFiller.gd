extends Node2D
class_name BoxFiller

@export var levelGrid : LevelGrid

var fblock : BoxHandler

func fillBlock(block : BoxHandler):
	# Safely replace previous filler
	if fblock != null:
		if is_instance_valid(fblock):
			fblock.call_deferred("_safe_remove_from_grid")
		fblock = null

	add_child(block)
	block.position = Vector2.ZERO
	fblock = block
	block._set_color(randi_range(0, 2))

	var time := 0.75
	while true:
		if fblock == null or not is_instance_valid(fblock):
			fblock = null
			return
		if fblock.blockValue >= 20:
			return
		if fblock.bType != fblock.BlockType.Block:
			return

		# spawn crystal
		var cts: Crystal = _spawn_crystal()
		if cts == null:
			return

		# connect so that crystal calls addToFBlock when it dies
		cts.on_die.connect(addToFBlock.bind(cts))
		cts.material = fblock.material
		cts.block_filler = self  # explicitly name it so Crystal knows who spawned it

		await get_tree().create_timer(time).timeout
		if fblock == null or not is_instance_valid(fblock):
			fblock = null
			return

		if time > 0.25 and time < 5.0:
			time *= 1.075


func _input(event: InputEvent) -> void:
	if fblock == null or not is_instance_valid(fblock):
		fblock = null
		return

	if event.is_action_pressed("release"):
		if is_instance_valid(fblock):
			levelGrid.addBlock(fblock)
		fblock = null


func _spawn_crystal() -> Crystal:
	var crys = load("res://Scenes/GameObjects/crystals.tscn").instantiate()
	add_child(crys)
	crys.position.y = -140
	return crys


func addToFBlock(Cys: Crystal):
	if fblock != null and is_instance_valid(fblock):
		if fblock.material == Cys.material:
			fblock._addToBlock()
