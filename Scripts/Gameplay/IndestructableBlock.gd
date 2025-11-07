extends BoxHandler

func _init() -> void:
	bType = BlockType.Indestructible

func _ready() -> void:
	_updateBoxText()

func _updateBoxText():
	$Label.text = ""

func _set_color(col : int):
	return
