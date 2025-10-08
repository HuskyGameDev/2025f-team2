extends Button

func _on_pressed() -> void:
	disable()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reroll"):
		disable()

func disable():
	self.disabled = true
	await get_tree().create_timer(1, false).timeout
	self.disabled = false
