#this script is for saving and loading user settings
#utilizes autoload in project settings
extends Node

const SETTINGS_FILE := "user://settings.cfg"

var resolution := Vector2i(1280, 720)
var fullscreen := false
var master_volume := 1.0

#placeholder keybinds, will fully implement later
var keybinds := {
	"up": "W",
	"down": "S",
	"left": "A",
	"right": "D"
}

#load user settings on start
func _ready():
	load_settings()

func save_settings():
	var config := ConfigFile.new()

	config.set_value("Video", "resolution", resolution)
	config.set_value("Video", "fullscreen", fullscreen)

	config.set_value("Audio", "master_volume", master_volume)

	config.set_value("Controls", "keybinds", keybinds)

	config.save(SETTINGS_FILE)

func load_settings():
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_FILE)
	
	if err != OK:
		# No settings file yet — defaults stay active
		return
	
	resolution = config.get_value("Video", "resolution", resolution)
	fullscreen = config.get_value("Video", "fullscreen", fullscreen)
	master_volume = config.get_value("Audio", "master_volume", master_volume)
	keybinds = config.get_value("Controls", "keybinds", keybinds)
