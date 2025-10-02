extends BoxHandler
class_name StaticEnemy

func _ready():
	bType = BoxHandler.BlockType.Enemy
	$Label.text = "S" # marker for static enemy

# Static enemies do nothing when a block is placed
func on_player_block_placed():
	pass

# handle collision with falling blocks
func on_block_collision(block: BoxHandler):
	# static enemies should have health in future
	pass
