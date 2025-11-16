extends EnemyHandler
class_name FloaterEnemy

func _ready() -> void:
	super._ready()
	# Ensure enemy sprite shows up properly
	if palletes.size() > 0:
		_set_color(color_index)
	modulate = Color(1, 1, 1, 1)
	visible = true

func on_enemy_turn() -> void:
	if levelGrid == null:
		return

	var dir = -1 if randf() < 0.5 else 1
	var new_x = clamp(bPosition.x + dir, 0, levelGrid.grid_size.x - 1)

	# only move if space is empty
	if levelGrid.blocks[bPosition.y][new_x] == null:
		levelGrid.blocks[bPosition.y][bPosition.x] = null
		bPosition.x = new_x
		levelGrid.blocks[bPosition.y][bPosition.x] = self
		levelGrid.setPositionOfBlockOnBoard(self)
