extends EnemyHandler
class_name StaticEnemy

func _ready():
	pass
	#$Label.text = str("S")

# Static enemy does nothing when player block is placed
func on_player_block_placed():
	pass
