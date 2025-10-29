extends Control

@export var label: Label
@export var textbox: Panel

# Complete control of everything that happens within the tutorial level

# upon loading in, pause immediately "welcome to Ribbon in the Wacky Warehouse!"
#"In a moment you will be thrown a block, and then magic crystals will start filling it"

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
#phase 2: unpauses, set timer, wait for block to fill to 10 -> phase 3  
	#or if player throws block -> phase 5
#level manager has a function create block that returns the block, use this to track it being filled

#phase 3: pauses again "throw block when filled"
#phase 4: stop crystal flow, wait for player to throw block
#phase 5: give player a block of same color to phase 2, already filled,
	#tell them to throw it and land it on the previous block
	#repeat until they get it right
#phase 6: give player an arrow, pause, explain the arrow
#phase 7: let player throw the arrow
#phase 8: after throw arrow, prefilled box to 19 and let 1 crystal fall, this is bomb
#phase 9: spawn an enemy, only give player block of same color

#goes to next phase
func _on_next_button_pressed() -> void:
	phase += 1
	print("next")
	match phase:
		1:
			setText("In a moment you will be thrown a block, and then magic crystals will start filling it!")
		2:
			makeTextDisappear()
			get_tree().paused = false
		4:
			print("phase 4?")
		_:
			pass

#self explanatory
func makeTextDisappear():
	textbox.visible = false

func makeTextreappear():
	textbox.visible = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
