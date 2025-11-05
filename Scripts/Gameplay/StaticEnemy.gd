extends EnemyHandler
class_name StaticEnemy

func _ready() -> void:
		#check for if there is an enemy stats resource
	if(enemyStats != null):
		#sets max to the higher and min to the lower
		if(enemyStats.staticHealth.y > enemyStats.staticHealth.x):
			min_health = enemyStats.staticHealth.x
			max_health = enemyStats.staticHealth.y
		else:
			min_health = enemyStats.staticHealth.y
			max_health = enemyStats.staticHealth.x
	else:
		print("No enemy stats resource")
	
	#if either health range has been set to under 1, default to 1
	if(min_health < 1):
		min_health = 1
	if(max_health < 1):
		max_health = 1
	super._ready()

func on_enemy_turn() -> void:
	# static enemy does nothing, it just occupies the grid cell
	pass
