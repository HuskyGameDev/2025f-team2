#Level State Script that can set Level Attrubutes at once while in same scene

class_name LevelState
extends Resource

@export var levelOrder : PlacementOrder
@export var blockOrder : BlockOrder
@export var enemyStats: LevelEnemyStats
@export var wlconditions: WinLossConditions
