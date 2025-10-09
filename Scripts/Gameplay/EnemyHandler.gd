extends BoxHandler
class_name EnemyHandler

@export var min_health: int = 5
@export var max_health: int = 20

var health: int
var action_timer: Timer

func _init() -> void:
	bType = BlockType.Enemy
	placed = true
	floating = false

func _ready() -> void:
	health = randi_range(min_health, max_health)
	_update_label()

	action_timer = Timer.new()
	action_timer.wait_time = randf_range(3.0, 5.0)
	action_timer.one_shot = false
	action_timer.timeout.connect(_on_enemy_turn)
	add_child(action_timer)
	action_timer.start()

func on_enemy_turn():
	pass

func _on_enemy_turn():
	if levelGrid == null:
		return
	on_enemy_turn()

func _update_label():
	if has_node("Label"):
		$Label.text = str(health)

func on_block_collision(block: BoxHandler):
	if block == null or not is_instance_valid(block):
		return
	if block.bColor != bColor:
		return

	var block_val = block.blockValue
	if block_val == null:
		return

	if block_val > health:
		block.blockValue = block_val - health
		block._updateBoxText()
		_remove_self_from_grid()
	elif block_val < health:
		health -= block_val
		_update_label()
		block._safe_remove_from_grid()
	else:
		block._safe_remove_from_grid()
		_remove_self_from_grid()

func _remove_self_from_grid():
	if levelGrid != null and bPosition != null:
		if bPosition.y >= 0 and bPosition.y < levelGrid.grid_size.y:
			if levelGrid.blocks[bPosition.y][bPosition.x] == self:
				levelGrid.blocks[bPosition.y][bPosition.x] = null
	call_deferred("queue_free")
