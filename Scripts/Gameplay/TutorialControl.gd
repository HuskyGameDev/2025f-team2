extends Control

@export var label: Label
@export var textbox: Panel
@export var levelmngr: LevelManager
@export var boxfill: BoxFiller
@export var levelgrid: LevelGrid

var firstBlock
var arrow
var bomb
var oneBlock
var enemy
var blockPlacedValue = 0
var bombExploded = false
var oneBlockPlaced = false

# Complete control of everything that happens within the tutorial level

func _ready() -> void:
	setText("Welcome to Ribbon in the Wacky Warehouse!")
	get_tree().paused = true

#easy way to set text
func setText(s: String):
	label.text = s

#tracks the current phase of the tutorial
#not exclusively incremented by the button
var phase = 0
#phase 0 is when the level is first entered: paused + welcome
#phase 1: "block will given"
#phase 2: unpauses, set timer, wait for block to fill to 4 -> phase 3  
	#or if player throws block -> phase 4
#phase 3: pauses again "throw block when filled"
#phase 4: stop crystal flow, wait for block to land
#phase 5: tell player to throw new block onto previous block
#phase 6: unpause and let them merge blocks
	#tell them to throw it and land it on the previous block
	#repeat until they get it right
#phase 7-8:  explain the arrow
#phase 9: give player an arrow, let player throw the arrow
#phase 10: "pretty cool huh?" 
#phase 11: prefilled box to 19
#phase 12: "that is one high value block!"
#phase 13: "add anything more to it and it'll explode!"
#phase 14: block with just one value, loops to phase 11 if not placed on bomb\
#phase 15-17: explain the enemies
#phase 18: kill the enemy
#phase 19: congratulations!
#phase 20: boots player to level select, with next level unlocked

#goes to next phase
func _on_next_button_pressed() -> void:
	phase += 1
	print("next")
	match phase:
		1:
			setText("In a moment you will be thrown a block, and then magic crystals will start filling it!")
		2:
			makeTextDisappear()
			firstBlock = levelmngr.spawnBlock(false)
		3:
			makeTextReappear()
			setText("Press 'Z' to place block into the gameboard (working name)")
		4:
			boxfill.dropCrystals = false
			makeTextDisappear()
		5:
			makeTextReappear()
			setText("Next, you will be given another block, land it on the already placed block to merge them!")
		6:
			bomb = levelmngr.spawnBlock(false)
			boxfill.dropCrystals = true
			makeTextDisappear()
		7:
			makeTextReappear()
			setText("Next you will be given an arrow")
		8:
			setText("When used, the arrow shifts everything in the grid by 1 in the direction it is facing")
		9:
			makeTextDisappear()
			if(boxfill.fblock != null):
				boxfill.fblock.queue_free()
			arrow = levelmngr.spawnSpecificBlock(levelmngr.arrow_node)
		10:
			makeTextReappear()
			setText("Pretty cool huh?")
		11:
			oneBlockPlaced = false
			makeTextDisappear()		
			if(boxfill.fblock != null):
				boxfill.fblock.queue_free()
			boxfill.dropCrystals = false
			bomb = levelmngr.spawnBlock(false)
			bomb.blockValue = 19
			bomb._updateBoxText()
			levelmngr.spawnBlocks = false
		12:
			makeTextReappear()
			setText("That is one big block!")
		13: 
			setText("Add anymore to that and it'll explode!")
		14:
			makeTextDisappear()
			if(boxfill.fblock != null):
				boxfill.fblock.queue_free()
			boxfill.dropCrystals = false
			oneBlock = levelmngr.spawnBlock(false)
			oneBlock.blockValue = 1
			oneBlock._updateBoxText()
		15:
			makeTextReappear()
			setText("And finally, we have enemies")
		16: 
			setText("These little guys are nuisances and must be cleard from the gameboard (working name)")
		17:
			setText("Drop blocks of the same color on them to destroy them!")
		18:
			makeTextDisappear()
			boxfill.dropCrystals = true
			levelmngr.spawnBlock(false)
		19:
			makeTextReappear()
			setText("You have beaten the tutorial! Have fun playing Ribbon in the Wacky Warehouse!")
		20:
			makeTextDisappear()
			get_tree().change_scene_to_file("res://Scenes/TestScenes/LevelSelect.tscn")
		_:
			pass

#self explanatory
func makeTextDisappear():
	textbox.visible = false
	get_tree().paused = false

func makeTextReappear():
	textbox.visible = true
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#any phase where spawning blocks after placing is necessary
	if(phase == 6 || phase == 18):
		levelmngr.spawnBlocks = true
	else:
		levelmngr.spawnBlocks = false
	
	
	#when it is phase 2, check for if the block is filled to 4
	if(phase == 2):
		if(firstBlock.blockValue >= 4):
			_on_next_button_pressed()
	
	#if during phase 2 the player throws their block, advance to phase 4
	if( phase == 2 && Input.is_action_pressed("release") ):
		phase = 4
		
	#phase 4 ends when firstblock has been placed
	if(phase == 4):
		if(firstBlock.placed):
			blockPlacedValue = firstBlock.blockValue
			_on_next_button_pressed()
			
	#track the first block value when placed, if it goes up during phase 6, it has merged
	if(phase == 6):
		if(firstBlock.blockValue > blockPlacedValue):
			_on_next_button_pressed()
			
	#once the arrow is release during phase 9, go next	
	#immediately remove all blocks
	if(phase == 9 && arrow == null):
		for i in levelgrid.get_all_blocks_in_board():
			levelgrid.removeBlock(i)
		_on_next_button_pressed()
		
	#once the player places the bomb, phase 11 is over
	if(phase == 11):
		if(bomb != null && bomb.placed):
			_on_next_button_pressed()
			
	#once the bomb explodes during phase 14, go to next, spawn a static enemy
	if(phase == 14):
		if(bomb == null && !bombExploded):
			bombExploded = true
			boxfill.dropCrystals = false
			await get_tree().create_timer(1, false).timeout
			for i in levelgrid.get_all_blocks_in_board():
				levelgrid.removeBlock(i)
			enemy = levelmngr.spawnSpecificEnemy(0, 0)
			_on_next_button_pressed()
	
	if(phase == 14):
		if(oneBlock != null && oneBlock.placed && !oneBlockPlaced):
			print("Pimp down")
			oneBlockPlaced = true
			oneBlock = null
			bomb = null
			for i in levelgrid.get_all_blocks_in_board():
				levelgrid.removeBlock(i)
			#do phase 11 stuff right here
			if(boxfill.fblock != null):
				boxfill.fblock.queue_free()
			boxfill.dropCrystals = false
			bomb = levelmngr.spawnBlock(false)
			bomb.blockValue = 19
			bomb._updateBoxText()
			phase = 11
			oneBlockPlaced = false
	
	if(phase == 18):
		if(enemy == null):
			_on_next_button_pressed()
