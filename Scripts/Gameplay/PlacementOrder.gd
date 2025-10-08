extends Resource
class_name PlacementOrder

enum BlockColor{Green, Red, Yellow}

enum BlockType{Block, Arrow, Indestructible, Enemy}

@export var typeOrder : Array[BlockType]
@export var colorOrder : Array[BlockColor]
