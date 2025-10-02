extends Button


func _on_pressed() -> void:
	get_parent().get_parent().visible=false
	get_tree().paused = false
