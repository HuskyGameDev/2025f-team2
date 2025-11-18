extends Sprite2D
class_name BoxHandler

enum BlockColor { Green, Red, Yellow }
enum BlockType { Block, Arrow, Indestructible, Enemy }

@export var palletes : Array[Material]

const bombThreshold = 20

var blockValue : int = 0
var levelGrid : LevelGrid
var bPosition : Vector2i

var bColor : BlockColor = BlockColor.Green
var bType : BlockType = BlockType.Block

var placed : bool

var prePlaced : bool = false
var prePlaceInvinc : int = 5

var floating : bool = true

signal on_placed
signal on_enemy_collide

#needed reference for several win conditions, passed in by level manager
var lvlMngr: LevelManager

func _ready() -> void:
	if palletes == null or palletes.size() == 0:
		push_warning("BoxHandler: palletes is empty or null.")
	else:
		var safe_index: int = clamp(int(bColor), 0, palletes.size() - 1)
		material = palletes[safe_index]
	_updateBoxText()

func _onFallTick():
	if floating:
		return
	if prePlaced:
		if prePlaceInvinc <= 0:
			prePlaced = false
		prePlaceInvinc -= 1
		return
	if bType == BlockType.Block:
		if levelGrid != null and levelGrid.get_all_blocks_in_board().find(self) == -1:
			# debugging fallback
			print("BoxHandler: not found in board list: color=", str(bColor), " value=", str(blockValue))
		
		if levelGrid != null:
			levelGrid.setPositionOfBlockOnBoard(self)
		if blockValue >= bombThreshold:
			if has_node("Explosion"):
				var explo = $Explosion
				if explo != null:
					remove_child(explo)
					get_parent().add_child(explo)
					explo.position = position
					explo.emitting = true
			if levelGrid != null:
				levelGrid.explode(self)
	if bPosition.y - 1 >= 0 and levelGrid != null:
		if levelGrid.blocks[bPosition.y-1][bPosition.x] == null:
			placed = false
		elif levelGrid.blocks[bPosition.y-1][bPosition.x] != null:
			levelGrid.moveBlockDown(self, levelGrid.active_block == self)
			return
	if placed:
		return
	levelGrid.moveBlockDown(self, levelGrid.active_block == self)

func _updateBoxText():
	if has_node("Label"):
		$Label.text = str(blockValue)

func _set_color(col: int):
	@warning_ignore("int_as_enum_without_cast")
	bColor = col
	if palletes != null and palletes.size() > 0:
		var safe_index: int = clamp(int(bColor), 0, palletes.size() - 1)
		material = palletes[safe_index]

func _addToBlock():
	blockValue += 1
	_updateBoxText()

func _removeToBlock():
	blockValue -= 1
	_updateBoxText()
	if blockValue <= 0:
		levelGrid.removeBlock(self)

func mergeBox(downBlock:BoxHandler):
	print("merge")
	if downBlock == null:
		return
	downBlock.blockValue += blockValue
	downBlock._updateBoxText()
	if levelGrid != null:
		levelGrid.blocks[bPosition.y][bPosition.x] = null
	lvlMngr.add_score(downBlock.blockValue,downBlock,true)
	queue_free()

func moveDown(control : bool = true):
	if (bPosition.y - 1) < 0:
		await levelGrid.place_block(self)
		if control and not prePlaced:
			levelGrid.next_block()
		return

	var below = levelGrid.blocks[bPosition.y - 1][bPosition.x]
	if below != null:
		# --- Enemy collision ---
		if below.bType == BlockType.Enemy and not prePlaced:
			# call enemy collision logic (enemy will handle color check/damage)
			if below.has_method("on_block_collision"):
				below.on_block_collision(self)
			# ensure this block is finalized so filler/next block can proceed
			if has_signal("on_enemy_collide"):
				emit_signal("on_enemy_collide")
			await levelGrid.place_block(self)
			if control:
				levelGrid.next_block()
			if has_signal("on_placed"):
				emit_signal("on_placed")
			return

		# --- Indestructible handling ---
		if below.bType == BlockType.Indestructible and not prePlaced:
			if control:
				await levelGrid.place_block(self)
				levelGrid.next_block()
			if has_signal("on_placed"):
				emit_signal("on_placed")
			return

		# --- Merge handling ---
		elif levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], below) and not prePlaced:
			levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], below)
			if control:
				levelGrid.next_block()
			if has_signal("on_placed"):
				emit_signal("on_placed")
			return

		# --- Normal stop ---
		else:
			if control and not prePlaced:
				await levelGrid.place_block(self)
				levelGrid.next_block()
			if has_signal("on_placed"):
				emit_signal("on_placed")
			return

	# --- Move Down if empty ---
	levelGrid.blocks[bPosition.y][bPosition.x] = null
	bPosition.y -= 1
	levelGrid.blocks[bPosition.y][bPosition.x] = self
	levelGrid.setPositionOfBlockOnBoard(self)
	await get_tree().create_timer(0.25).timeout
	if levelGrid.blocks[bPosition.y - 1][bPosition.x] == null:
		placed = false

func moveLeft(merge : bool = false):
	if (bPosition.x - 1) < 0:
		return
	if levelGrid.blocks[bPosition.y][bPosition.x - 1] != null:
		if merge:
			if levelGrid.blocks[bPosition.y][bPosition.x - 1].bType == BlockType.Indestructible:
				return
			if levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x - 1]):
				levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x - 1])
		return
	levelGrid.blocks[bPosition.y][bPosition.x] = null
	bPosition.x -= 1
	levelGrid.blocks[bPosition.y][bPosition.x] = self
	levelGrid.setPositionOfBlockOnBoard(self)

func moveRight(merge : bool = false):
	if (bPosition.x + 1) > levelGrid.grid_size.x - 1:
		return
	if levelGrid.blocks[bPosition.y][bPosition.x + 1] != null:
		if merge:
			if levelGrid.blocks[bPosition.y][bPosition.x + 1].bType == BlockType.Indestructible:
				return
			if levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x + 1]):
				levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[bPosition.y][bPosition.x + 1])
		return
	levelGrid.blocks[bPosition.y][bPosition.x] = null
	bPosition.x += 1
	levelGrid.blocks[bPosition.y][bPosition.x] = self
	levelGrid.setPositionOfBlockOnBoard(self)

func hardDrop():
	var y = bPosition.y
	while y >= 0:
		if y == 0:
			levelGrid.blocks[bPosition.y][bPosition.x] = null
			bPosition.y = y
			levelGrid.blocks[bPosition.y][bPosition.x] = self
			levelGrid.setPositionOfBlockOnBoard(self)
			await levelGrid.place_block(self)
			levelGrid.next_block()
			emit_signal("on_placed")
			return
		if (levelGrid.blocks[y - 1][bPosition.x] == null):
			y -= 1
			continue
		if levelGrid.blocks[y - 1][bPosition.x].bType == BlockType.Arrow:
			y -= 1
			continue
		if levelGrid.blocks[y - 1][bPosition.x].bType == BlockType.Indestructible:
			levelGrid.blocks[bPosition.y][bPosition.x] = null
			bPosition.y = y
			levelGrid.blocks[bPosition.y][bPosition.x] = self
			levelGrid.setPositionOfBlockOnBoard(self)
			await levelGrid.place_block(self)
			levelGrid.next_block()
			emit_signal("on_placed")
			return
		if levelGrid.blocks[y - 1][bPosition.x].bType == BlockType.Enemy:
			var enemy = levelGrid.blocks[y - 1][bPosition.x]
			if enemy.has_method("on_block_collision"):
				enemy.on_block_collision(self)
			emit_signal("on_enemy_collide")
			await levelGrid.place_block(self)
			bPosition.y = y
			levelGrid.next_block()
			emit_signal("on_placed")
			return
		# merge or place at landing spot
		if levelGrid.blockCheck(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[y - 1][bPosition.x]):
			levelGrid.mergeBlocks(levelGrid.blocks[bPosition.y][bPosition.x], levelGrid.blocks[y - 1][bPosition.x])
			levelGrid.next_block()
			emit_signal("on_placed")
			return
		else:
			levelGrid.blocks[bPosition.y][bPosition.x] = null
			bPosition.y = y
			levelGrid.blocks[bPosition.y][bPosition.x] = self
			levelGrid.setPositionOfBlockOnBoard(self)
			await levelGrid.place_block(self)
			levelGrid.next_block()
			emit_signal("on_placed")
			return

func _safe_remove_from_grid():
	if levelGrid != null:
		levelGrid.blocks[bPosition.y][bPosition.x] = null
	call_deferred("queue_free")

func placeBlock():
	placed = true
	lvlMngr.add_score(blockValue, self)
	emit_signal("on_placed")

func onAdd():
	placed = false
	floating = false
