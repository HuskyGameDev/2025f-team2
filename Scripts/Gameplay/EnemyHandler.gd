extends BoxHandler
class_name EnemyHandler

@export var max_health: int = 3
var health: int

func _init() -> void:
	bType = BlockType.Enemy
	health = max_health
	placed = true  # enemies don't fall
	floating = false

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die():
	if levelGrid != null:
		levelGrid.blocks[bPosition.y][bPosition.x] = null
	queue_free()

# called when a player block is placed
func on_player_block_placed():
	pass  # override in subclasses

func on_block_collision(block: BoxHandler):
	# Default: damage = block value
	take_damage(block.blockValue)
