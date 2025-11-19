# SettingsButton.gd
extends Button

#set this var to whatever scene you want this button to send you to
@export var settings : Control

func _ready() -> void:
	if name == "PlayGame":
		grab_focus()

#When the button is pressed, loads the next scene
func _on_pressed() -> void:
	settings.inShow()
	settings.connect("on_close", returnFocus)

func returnFocus():
	grab_focus()
