# SettingsMenu.gd
extends Control

signal on_close

#to go back to main menu
@export var targetScene: String = "res://Scenes/TestScenes/MainMenu.tscn";

@onready var resolution_dropdown = $Panel/ResolutionDropdown
@onready var fullscreen_toggle = $Panel/FullscreenToggle
@onready var volume_slider = $Panel/VolumeSlider
@onready var close_button = $Panel/CloseButton

# Example resolutions to offer
var resolutions := [
	Vector2i(320, 180),    # 4:3 classic
	Vector2i(640, 320),    # 4:3 classic
	Vector2i(960, 540),    # 4:3 classic
	Vector2i(1280, 720),    # 4:3 classic
	Vector2i(1600, 900),    # 4:3 classic
	Vector2i(1920, 1080),    # 4:3 classic
	Vector2i(2240, 1260),    # 4:3 classic
	Vector2i(2560, 1440)    # 4:3 classic
]

func inShow():
	show()
	populate_resolution_dropdown()
	load_current_settings()
	fullscreen_toggle.grab_focus()
	resolution_dropdown.item_selected.connect(_on_resolution_selected)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	volume_slider.value_changed.connect(_on_volume_changed)
	close_button.pressed.connect(_on_save_pressed)


func populate_resolution_dropdown():
	resolution_dropdown.clear()
	for res in resolutions:
		resolution_dropdown.add_item("%d x %d" % [res.x, res.y])

func load_current_settings():
	# Load from autoload
	var s = SettingsData

	# Resolution
	var index := resolutions.find(s.resolution)
	if index != -1:
		resolution_dropdown.select(index)

	# Fullscreen
	fullscreen_toggle.button_pressed = s.fullscreen
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if s.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	)

	# Volume
	volume_slider.value = s.master_volume
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(s.master_volume)
	)

func _on_resolution_selected(index):
	var res = resolutions[index]
	SettingsData.resolution = res
	DisplayServer.window_set_size(res)

func _on_fullscreen_toggled(pressed: bool):
	SettingsData.fullscreen = pressed
	if pressed:
		#go fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		#return to windowed mode
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# IMPORTANT: apply the saved resolution in case it was altered while fullscreen
		DisplayServer.window_set_size(SettingsData.resolution)

func _on_volume_changed(value):
	SettingsData.master_volume = value
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(value)
	)

#save settings and go back to main menu
func _on_save_pressed():
	on_close.emit()
	SettingsData.save_settings()
	get_tree().paused = false
	#GlobalSceneLoader.load_level(targetScene)
	hide()
