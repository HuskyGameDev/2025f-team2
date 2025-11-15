extends BoxHandler

func _onFallTick():
	return

func _init() -> void:
	bType = BlockType.Indestructible

func _ready() -> void:
	blockValue = 0
	_updateBoxText()

func _updateBoxText():
	$Label.text = ""

func _set_color(col : int):
	return 
