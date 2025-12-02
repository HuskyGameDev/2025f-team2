extends Node

signal onTransitionDone

var isLoading = false


func debug_load(targetScene: String):
	get_tree().change_scene_to_file(targetScene)

func load_level(targetScene: String, levelState : LevelState = null, worldMapPos: int = -1):
	if isLoading:
		return
	isLoading = true
	var transition : Transition = load("res://Scenes/UI_Objects/Transitions/transition1.tscn").instantiate()
	add_child(transition)
	await transition.animator.animation_finished
	# Request to load the target scene:
	ResourceLoader.load_threaded_request(targetScene)
	var loading_status : int
	var progress : Array[float]
	var success : bool
	while(true):
		# Update the status:
		loading_status = ResourceLoader.load_threaded_get_status(targetScene, progress)
		# Check the loading status:
		match loading_status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				print(progress[0] * 100) 
			ResourceLoader.THREAD_LOAD_LOADED:
				
				success = true
				break
			ResourceLoader.THREAD_LOAD_FAILED:
				# Well some error happend:
				print("Error. Could not load Resource")
				success = false
				break
		await get_tree().process_frame
	await get_tree().create_timer(0.25).timeout
	if success:
		# When done loading, change to the target scene:
		var scene = ResourceLoader.load_threaded_get(targetScene)
		get_tree().change_scene_to_packed(scene)
		get_tree().paused = false
		transition.lowerTransition()
		transition.animator.animation_finished.connect(emitTransDone)
		transition.kill_on_finish()
		if levelState != null:
			while(get_tree().current_scene == null):
				await get_tree().process_frame
			if get_tree().current_scene is LevelManager:
				get_tree().current_scene.setLevelState(levelState)
				return
			if get_tree().current_scene.get_child(0) is LevelManager:
				get_tree().current_scene.get_child(0).setLevelState(levelState)
				return
		if worldMapPos != -1:
			while(get_tree().current_scene == null):
				await get_tree().process_frame
			if get_tree().current_scene is WorldMap:
				get_tree().current_scene.pos = worldMapPos
				return
			if get_tree().current_scene.get_child(0) is WorldMap:
				get_tree().current_scene.get_child(0).current_scene.pos = worldMapPos
				return

func emitTransDone(name:String):
	onTransitionDone.emit()
	isLoading = false
