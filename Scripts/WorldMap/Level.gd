extends Resource

class_name Level

enum LevelType{Tutorial, Time_Attack, Exterminate, Score_Attack}

@export var levelName = "Tutorial"
@export var levelType : LevelType = LevelType.Tutorial
@export var scene : String = "res://Scenes/ActualLevels/Level_0 (template)/Level_0.tscn"
@export var levelObject : LevelState

func getLevelTypeName(levelType : LevelType) -> String:
	match levelType:
		LevelType.Tutorial:
			return "Tutorial!"
		LevelType.Time_Attack:
			return "Time Attack!"
		LevelType.Exterminate:
			return "Extermination!"
		LevelType.Score_Attack:
			return "Score Attack!"
		_:
			return "Default."
