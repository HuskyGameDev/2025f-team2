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
var holdCooldown = 2
var canHold = true


func fillBlock(block : BoxHandler):
	var bok = block
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
			break
			return
		if fblock.bType == fblock.BlockType.Block:
			var cts : Crystal = spawnCrystal()
			cts.on_die.connect(addToFBlock.bind(cts, bok))
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
	if event.is_action_pressed("hold") && canHold:
		#check for already stored block, swap if there is
		if storedblock != null:
			#temporarily tracks the stored block
			var tempblock = storedblock
			#shrink current fblock and move it to storage
			fblock.scale = Vector2(0.5,0.5)
			fblock.position = storage.position
			storedblock = fblock
			fblock = null
			
			#regrow old stored block
			tempblock.scale = Vector2(1,1)
			fillBlock(tempblock)
			setHoldCool()
			
		#if there is not a block already stored, store current
		elif storedblock == null:
			#set storedblock and unset fblock
			storedblock = fblock
			storedblock.position = storage.position
			storedblock.scale = Vector2(0.5,0.5)
			#gets the next block
			fblock = null
			levelGrid.next_block()
			
			#show the cooldown of the hold on the box
			setHoldCool()
		
func setHoldCool():
	storage.get_child(0).visible = true
	storage.get_child(0).scale = Vector2(16,16)
	create_tween().tween_property(storage.get_child(0),"scale", Vector2(0, 16), holdCooldown)
	canHold = false
	await get_tree().create_timer(holdCooldown, false).timeout
	storage.get_child(0).visible = false
	canHold = true

func spawnCrystal() -> Crystal:
	var crys = load("res://Scenes/GameObjects/crystals.tscn").instantiate()
	add_child(crys)
	crys.position.y = -140
	return crys
	
func addToFBlock(Cys : Crystal, oblock: BoxHandler):
	if fblock != null && oblock == fblock:
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
