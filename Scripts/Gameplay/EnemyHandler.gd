extends BoxHandler
class_name EnemyHandler

@export var min_health: int = 5
@export var max_health: int = 20
@export var action_min_seconds: float = 3.0
@export var action_max_seconds: float = 5.0

var health: int = 0
var action_timer: Timer
@export var color_index: int = 0  # block color

func _init() -> void:
	bType = BlockType.Enemy
	placed = true
	floating = false

func _ready() -> void:
	# just setup the timer here
	action_timer = Timer.new()
	action_timer.one_shot = false
	action_timer.wait_time = randf_range(action_min_seconds, action_max_seconds)
	action_timer.timeout.connect(_on_action_timer_timeout)
	add_child(action_timer)
	action_timer.start()

func _on_action_timer_timeout() -> void:
	on_enemy_turn()

func on_enemy_turn() -> void:
	pass

func _update_label() -> void:
	if has_node("Label"):
		$Label.text = str(health)

func take_damage(dmg: int) -> void:
	health -= dmg
	_update_label()
	if health <= 0:
		if levelGrid != null and bPosition != null:
			if levelGrid.blocks[bPosition.y][bPosition.x] == self:
				levelGrid.blocks[bPosition.y][bPosition.x] = null
		queue_free()

func _set_color(index: int) -> void:
	color_index = index
	if palletes.size() == 0:
		push_warning("No palette assigned to enemy!")
		return
	if index < 0 or index >= palletes.size():
		index = 0
	material = palletes[index]

# Spawn in the grid
func spawn_in_grid(grid: LevelGrid, pos: Vector2i, col_idx: int = -1) -> void:
	if grid == null:
		push_error("spawn_in_grid: grid is null")
		return

	levelGrid = grid

	if col_idx == -1:
		col_idx = randi_range(0, palletes.size()-1)
	color_index = col_idx
	_set_color(color_index)

	bPosition = pos
	grid.blocks[bPosition.y][bPosition.x] = self
	grid.setPositionOfBlockOnBoard(self)

	# random health
	health = randi_range(min_health, max_health)
	_update_label()
