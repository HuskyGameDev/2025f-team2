extends Resource

class_name Block

enum BlockType
{
	Standard,
	Indestructable, 
	Enemy
}

enum BlockColor
{
	Green, 
	Red, 
	Yellow,
	Random
}

@export var blockType : BlockType
@export var blockColor : BlockColor
@export var value : int = 5
