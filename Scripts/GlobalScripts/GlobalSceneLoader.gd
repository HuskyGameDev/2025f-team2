extends Node

func debug_load(targetScene: String):
	get_tree().change_scene_to_file(targetScene)

func load_level(targetScene: String):
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
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(targetScene))
		transition.lowerTransition()
		transition.kill_on_finish()
