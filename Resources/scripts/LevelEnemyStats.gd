class_name LevelEnemyStats
extends Resource

#painter stats
@export_group("EnemySpawningPerBlock")
#x is the min blocks per spawn, y is the max, y must be > x
@export var enemyPerBlock: Vector2i = Vector2i(3,5)

#painter stats
@export_group("Static")
#the minimum and maximum health of the painter
@export var staticHealth: Vector2i = Vector2i(5,10)

#painter stats
@export_group("Floater")
#the minimum and maximum health of the painter
@export var floaterHealth: Vector2i = Vector2i(3,5)
#the minimum and maximum action speed of the painter
@export var floaterActionSpeed: Vector2 = Vector2(2,4)

#painter stats
@export_group("Painter")
#the minimum and maximum health of the painter
@export var painterHealth: Vector2i = Vector2i(3,5)
#the minimum and maximum action speed of the painter
@export var painterActionSpeed: Vector2 = Vector2(3,5)
