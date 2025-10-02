extends Control

#makes it so that the esc button can pause and unpause
var gamePaused = false

# if the pause button is pressed, bring up the pause menu
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_pausePressed()
			
func _pausePressed():
	if(!gamePaused):
		gamePaused = true
		get_tree().paused = true
		self.visible = true
	else:
		gamePaused = false
		get_tree().paused = false
		self.visible = false
