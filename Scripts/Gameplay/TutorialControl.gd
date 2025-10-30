extends Control

@export var label: Label
@export var textbox: Panel
@export var levelmngr: LevelManager
@export var boxfill: BoxFiller

var firstBlock

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
#phase : give player an arrow, pause, explain the arrow
#phase : let player throw the arrow
#phase : after throw arrow, prefilled box to 19 and let 1 crystal fall, this is bomb
#phase : spawn an enemy, only give player block of same color

#goes to next phase
func _on_next_button_pressed() -> void:
	phase += 1
	print("next")
	match phase:
		1:
			setText("In a moment you will be thrown a block, and then magic crystals will start filling it!")
		2:
			makeTextDisappear()
			firstBlock = levelmngr.spawnBlock()
		3:
			makeTextReappear()
			setText("Press 'Z' to place block into the gameboard (working name)")
		4:
			boxfill.dropCrystals = false
			makeTextDisappear()
		5:
			makeTextReappear()
			setText("You will be given another block, land it on the already placed block to merge them!")
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
	#when it is phase 2, check for if the block is filled to 4
	if(phase == 2):
		if(firstBlock.blockValue >= 4):
			_on_next_button_pressed()
	#if during phase 2 the player throws their block, advance to phase 4
		
	#phase 4 ends when firstblock has been placed
	if(phase == 4):
		if(firstBlock.placed):
			_on_next_button_pressed()
