extends Node2D

class_name BoxFiller

@export var levelGrid : LevelGrid
@onready var ribbon : RibbonAnimator = $Ribbon

var fblock : BoxHandler
var startingTime = 0.75


func fillBlock(block : BoxHandler):
	var bok = fblock
	if fblock != null:
		fblock.queue_free()
	add_child(block)
	block.position = Vector2(0,-200)
	fblock = block
	await create_tween().tween_property(fblock, "position", Vector2(0,0), 0.5).finished
	ribbon.setGetBox()
	var time = startingTime
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
			if time > 0.25 and time < 7.0:
				time *= 1.095
		else:
			break
			return

func _input(event: InputEvent) -> void:
	if fblock == null:
		return
	if event.is_action_pressed("reroll"):
		reroll()
	if event.is_action_pressed("release"):
		if fblock.blockValue >= 20:
			return
		var aBlock : BoxHandler = fblock
		fblock = null
		ribbon.setHop()
		await get_tree().create_timer(0.2, false).timeout
		create_tween().tween_property(aBlock,"position", Vector2(0, -200), .75)
		await ribbon.waitUntilFinish()
		levelGrid.addBlock(aBlock)
		
func _on_reroll_button_pressed() -> void:
	reroll()
	
func reroll():
	if fblock == null:
		return
	fblock.queue_free()
	levelGrid.next_block()
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
