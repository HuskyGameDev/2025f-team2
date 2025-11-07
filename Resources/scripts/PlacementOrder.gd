class_name PlacementOrder
extends Resource

enum BlockColor { Green, Red, Yellow }
enum BlockType { Block, Arrow, Indestructible, Enemy }

@export var typeOrder: Array[BlockType] = [BlockType.Block, BlockType.Arrow, BlockType.Indestructible, BlockType.Enemy]
@export var colorOrder: Array[BlockColor] = [BlockColor.Green, BlockColor.Red, BlockColor.Yellow]

@export var enemyTypeOrder: Array[String] = ["StaticEnemy", "FloaterEnemy", "PainterEnemy"]
