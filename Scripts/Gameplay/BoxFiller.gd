extends Node2D

class_name BoxFiller

@export var levelGrid : LevelGrid
@onready var ribbon : RibbonAnimator = $Ribbon

#off switch for the crytals (tutorial)
@export var dropCrystals = true

var fblock : BoxHandler
var storedblock: BoxHandler
@export var storage: Node
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
		if !dropCrystals:
			break
			return
		if fblock.blockValue >= BoxHandler.bombThreshold:
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
			continue
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
		#stops release when block is at value 0
		if fblock.blockValue < 1 && fblock.bType == BoxHandler.BlockType.Block:
			return
		if fblock.blockValue >= BoxHandler.bombThreshold:
			return
		var aBlock : BoxHandler = fblock
		fblock = null
		ribbon.setHop()
		await get_tree().create_timer(0.2, false).timeout
		create_tween().tween_property(aBlock,"position", Vector2(0, -200), .75)
		await ribbon.waitUntilFinish()
		levelGrid.addBlock(aBlock)
	#store fblock
	if event.is_action_pressed("left"):
		#check for already stored block, swap if there is
		if storedblock != null:
			#temporarily stores the fblock
			var tempblock = storedblock
			#sets storedblock to the temp block and positions it correctly
			storedblock = fblock
			remove_child(storedblock)
			storage.add_child(storedblock)
			storedblock.scale = Vector2(0.5,0.5)
			fblock = null
			
			#tempblock is the new fblock, positions the block correctly and then starts filling
			storage.remove_child(tempblock)
			add_child(tempblock)
			tempblock.scale = Vector2(1,1)
			
			await get_tree().create_timer(0.2, false).timeout
			
			fblock = tempblock
			tempblock = null
			
		#if there is not a block already stored, store current
		elif storedblock == null:
			#set storedblock and unset fblock
			storedblock = fblock
			#repositions the stored block
			remove_child(storedblock)
			storage.add_child(storedblock)
			storedblock.scale = Vector2(0.5,0.5)
			
			#gets next block
			fblock = null
			levelGrid.next_block()

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
			if fblock.has_node("Explosion") && fblock.blockValue > BoxHandler.bombThreshold-1:
				var explo = fblock.get_child(1)
				if explo != null:
					fblock.remove_child(explo)
					get_parent().add_child(explo)
					fblock.queue_free()
					ribbon.setExplode()
					explo.position = position
					explo.emitting = true
					if(randi() % 5 > 3):
						ribbon.visible = false
					await ribbon.waitUntilFinish()
					levelGrid.levelManager.forceLoss()
