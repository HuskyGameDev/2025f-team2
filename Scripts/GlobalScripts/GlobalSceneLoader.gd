extends Node

func debug_load(targetScene: String):
	get_tree().change_scene_to_file(targetScene)
