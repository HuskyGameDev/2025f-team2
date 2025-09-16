extends Sprite2D
class_name BoxHandler

enum BlockColor{Green, Red}

@export var palletes : Array[Material]

var blockValue : int = 0
var levelGrid : LevelGrid

var bPosition : Vector2i

var bColor : BlockColor = BlockColor.Green

var placed : bool

func _ready() -> void:
	material = palletes[bColor]
	_updateBoxText()
	
func _onFallTick():
	if placed:
		return
	levelGrid.moveBlockDown(self)

func _updateBoxText():
	$Label.text = str(blockValue)

func _set_color(col : int):
	bColor = col
	material = palletes[bColor]

func _addToBlock():
	blockValue += 1
	_updateBoxText()
