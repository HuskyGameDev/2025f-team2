extends BoxHandler
class_name EnemyHandler

@export var max_health: int = 10
var health: int

func _init() -> void:
	bType = BlockType.Enemy
	health = max_health

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free() # remove enemy when dead

func on_block_collision(block: BoxHandler) -> void:
	# block value = damage
	take_damage(block.bValue)
	block.queue_free() # destroy the falling block on impact
