extends BoxHandler
class_name EnemyHandler

@export var min_health: int = 5
@export var max_health: int = 20
@export var action_min_seconds: float = 3.0
@export var action_max_seconds: float = 5.0

#reference to enemyStats passed in by level manager, or manually if needed
var enemyStats: LevelEnemyStats

var health: int = 0:
	set(value):
		health = value
		if(health > highestHealth):
			highestHealth = health
var highestHealth = 0
var action_timer: Timer

# Use the shared palletes from BoxHandler (palletes)
@export var color_index: int = 0

func _init() -> void:
	# mark as enemy block so other systems know
	bType = BlockType.Enemy
	placed = true
	floating = false

func _ready() -> void:
	# pick health randomly if not already set
	health = randi_range(min_health, max_health)
	_update_label()

	# setup action timer (enemies act periodically)
	action_timer = Timer.new()
	action_timer.one_shot = false
	action_timer.wait_time = randf_range(action_min_seconds, action_max_seconds)
	action_timer.timeout.connect(_on_action_timer_timeout)
	add_child(action_timer)
	action_timer.start()

	# ensure palette color applied if palletes present
	if palletes != null and palletes.size() > 0:
		var safe_idx = clamp(color_index, 0, palletes.size() - 1)
		material = palletes[safe_idx]

	# register in the grid if assigned already
	if levelGrid != null and bPosition != null:
		if bPosition.y >= 0 and bPosition.y < levelGrid.grid_size.y and bPosition.x >= 0 and bPosition.x < levelGrid.grid_size.x:
			levelGrid.blocks[bPosition.y][bPosition.x] = self
			levelGrid.setPositionOfBlockOnBoard(self)

func _on_action_timer_timeout() -> void:
	on_enemy_turn()

func on_enemy_turn() -> void:
	# default does nothing — subclasses override
	pass

func _update_label() -> void:
	if has_node("Label"):
		$Label.text = str(health)

func take_damage(dmg: int) -> void:
	health -= dmg
	_update_label()
	if health <= 0:
		_remove_self_from_grid()

func _remove_self_from_grid() -> void:
	if levelGrid != null and bPosition != null:
		if bPosition.y >= 0 and bPosition.y < levelGrid.grid_size.y and bPosition.x >= 0 and bPosition.x < levelGrid.grid_size.x:
			if levelGrid.blocks[bPosition.y][bPosition.x] == self:
				levelGrid.blocks[bPosition.y][bPosition.x] = null
	lvlMngr.enemiesKilled += 1
	lvlMngr.enemiesAlive -= 1
	lvlMngr.add_score(highestHealth,self)
	call_deferred("queue_free")

func _set_color(index: int) -> void:
	color_index = index
	if palletes == null or palletes.size() == 0:
		push_warning("EnemyHandler: palletes not set.")
		return
	var safe = clamp(index, 0, palletes.size() - 1)
	material = palletes[safe]

# Called by LevelManager (or LevelGrid) to place enemy in grid and choose color
func spawn_in_grid(grid: LevelGrid, pos: Vector2i, col_idx: int = -1) -> void:
	if grid == null:
		push_error("spawn_in_grid: grid is null")
		return
	levelGrid = grid

	# choose color if not specified
	if palletes == null or palletes.size() == 0:
		# try to safely pull palletes from the block scene if possible
		if grid.block_node != null:
			var tmp = grid.block_node.instantiate()
			if "palletes" in tmp:
				palletes = tmp.palletes
			if is_instance_valid(tmp):
				tmp.queue_free()

	if col_idx == -1 and palletes != null and palletes.size() > 0:
		col_idx = randi_range(0, palletes.size() - 1)
	elif col_idx == -1:
		col_idx = 0

	_set_color(col_idx)

	bPosition = pos
	placed = true
	floating = false

	# register and set transform
	if bPosition.y >= 0 and bPosition.y < grid.grid_size.y and bPosition.x >= 0 and bPosition.x < grid.grid_size.x:
		grid.blocks[bPosition.y][bPosition.x] = self
		grid.setPositionOfBlockOnBoard(self)

	# randomize health on spawn
	health = randi_range(min_health, max_health)
	_update_label()

# Called by BoxHandler when a block collides with this enemy
func on_block_collision(block: BoxHandler) -> void:
	if block == null or not is_instance_valid(block):
		return

	# If colors don't match, do nothing special - BoxHandler will place the block as usual.
	if block.bColor != int(color_index):
		return

	# same-color interaction: exchange damage similar to earlier branch logic.
	var block_val : int = block.blockValue
	if block_val == null:
		return

	if block_val > health:
		# block survives with reduced value
		block.blockValue = block_val - health
		block._updateBoxText()
		_remove_self_from_grid()
	elif block_val < health:
		# enemy takes damage and survives; block is removed
		health -= block_val
		_update_label()
		block._safe_remove_from_grid()
	else:
		# equal -> both removed
		block._safe_remove_from_grid()
		_remove_self_from_grid()
