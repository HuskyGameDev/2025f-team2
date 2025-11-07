@tool
class_name WinLossConditions
extends Resource

@export_group("Win cons")
#win condition for if a certain number of enemies are killed
@export var killEnemiesCondition: bool:
	set(value):
		killEnemiesCondition = value
		property_list_changed.emit()
	get():
		return killEnemiesCondition
@export var killEnemies: int

#win condition for if a certain score is achieved
@export var achieveScoreCondition: bool:
	set(value):
		achieveScoreCondition = value
		property_list_changed.emit()
@export var targetScore: int

#win condition for if a certain number of blocks are removed
@export var removeBlocksCondition: bool:
	set(value):
		removeBlocksCondition = value
		property_list_changed.emit()
@export var targetRemovedBlocks: int

#win condition for the total value of blocks on the board
@export var scoreOnBoardWinCondition: bool:
	set(value):
		scoreOnBoardWinCondition = value
		property_list_changed.emit()
#win condition for the total value of specific color
@export var scoreColorOnBoardWinCondition: bool:
	set(value):
		scoreColorOnBoardWinCondition = value
		property_list_changed.emit()
@export var targetColor: BoxHandler.BlockColor
@export var scoreOnBoardTarget: int

@export_group("Lose cons")
#lose if the timer runs out
@export var timerLoseCondition: bool:
	set(value):
		timerLoseCondition = value
		property_list_changed.emit()
@export var timeTillLoss: int

#lose if too many blocks are used
@export var blockLoseCondition: bool:
	set(value):
		blockLoseCondition = value
		property_list_changed.emit()
@export var blockLossLimit: int

#lose if too many bombs went off
@export var tooManyBombsCondition: bool:
	set(value):
		tooManyBombsCondition = value
		property_list_changed.emit()
@export var bombLimit: int

#lose if there are more than enemies than the enemy limit
@export var tooManyEnemiesCondition: bool:
	set(value):
		tooManyEnemiesCondition = value
		property_list_changed.emit()
@export var enemyLimit: int

#lose if the total block value on the board is over the limit
@export var scoreOnBoardLoseCondition: bool:
	set(value):
		scoreOnBoardLoseCondition = value
		property_list_changed.emit()
@export var scoreOnBoardLimit: int

#changes inspector based on if bools are true
func _validate_property(property: Dictionary) -> void:
	match property.name:
		"killEnemies":
			property.usage = PROPERTY_USAGE_DEFAULT if killEnemiesCondition else PROPERTY_USAGE_NO_EDITOR
		"targetScore":
			property.usage = PROPERTY_USAGE_DEFAULT if achieveScoreCondition else PROPERTY_USAGE_NO_EDITOR
		"targetRemovedBlocks":
			property.usage = PROPERTY_USAGE_DEFAULT if removeBlocksCondition else PROPERTY_USAGE_NO_EDITOR
		"scoreOnBoardTarget":
			property.usage = PROPERTY_USAGE_DEFAULT if scoreOnBoardWinCondition else PROPERTY_USAGE_NO_EDITOR
		"scoreColorOnBoardWinCondition":
			property.usage = PROPERTY_USAGE_DEFAULT if scoreOnBoardWinCondition else PROPERTY_USAGE_NO_EDITOR
		"targetColor":
			property.usage = PROPERTY_USAGE_DEFAULT if scoreColorOnBoardWinCondition else PROPERTY_USAGE_NO_EDITOR
		"timeTillLoss":
			property.usage = PROPERTY_USAGE_DEFAULT if timerLoseCondition else PROPERTY_USAGE_NO_EDITOR
		"blockLossLimit":
			property.usage = PROPERTY_USAGE_DEFAULT if blockLoseCondition else PROPERTY_USAGE_NO_EDITOR
		"bombLimit":
			property.usage = PROPERTY_USAGE_DEFAULT if tooManyBombsCondition else PROPERTY_USAGE_NO_EDITOR
		"enemyLimit":
			property.usage = PROPERTY_USAGE_DEFAULT if tooManyEnemiesCondition else PROPERTY_USAGE_NO_EDITOR
		"scoreOnBoardLimit":
			property.usage = PROPERTY_USAGE_DEFAULT if scoreOnBoardLoseCondition else PROPERTY_USAGE_NO_EDITOR
