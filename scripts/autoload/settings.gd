extends Node


###### Signals ######

# Thrown when the sound state is changed
signal sound_state_changed
# Thrown when the colors are changed
signal colors_changed


###### Variables ######

# Loaded settings file
var settingsFile : ConfigFile
# Settings menu scene
var settingsMenuScene := preload("res://scenes/gui/SettingsMenu.tscn")
# Current theme being used
var current_theme : Theme
# Current sound state, when false the game is muted
var sound_state : bool
# Current color palette selected
var selected_palette : int
# Color palettes available
var palettes : Array
# Settings file path
var path : String


###### Functions ######

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settingsFile = ConfigFile.new()
	path = "user://settings.cfg"
	var err = settingsFile.load(path)
	assert(err == OK)
	_set_sound(!settingsFile.get_value("general", "mute"))
	_set_colors(
		settingsFile.get_value("general", "palette"),
		settingsFile.get_value("general", "color_palettes")
	)
	current_theme = null # TODO: Load default theme

# Sets a connection to the object and method given
# when updating the color palette and disconnects it when the
# object exits the tree
func request_color_updates(node : Node, method : String) -> void:
	# TODO: Implement with groups
	self.connect("colors_changed", node, method)
	# TODO: Disconnect
	
# Sets a connection to the object and method given
# when updating the sound settings and disconnects it when the
# object exits the tree
func request_sound_updates(node : Node, method : String) -> void:
	# TODO: Implement with groups
	self.connect("sound_state_changed", node, method)
	# TODO: Disconnect

# Sets the sound state to on or off
func _set_sound(on : bool) -> void:
	sound_state = on
	emit_signal("sound_state_changed")

# Saves a sound state change to file
func _save_sound(on : bool) -> void:
	var prev_sound = !settingsFile.get_value("general", "mute")
	# As the sound state changes on toggle, sound_state is already
	# up to date, so there's no need to use _set_sound
	if prev_sound != on:
		settingsFile.set_value("general", "mute", !sound_state)
		settingsFile.save(path)

# Saves a color change to file
func _save_colors(selection : int) -> void:
	if selected_palette != selection:
		_set_colors(selection, palettes)
		settingsFile.set_value("general", "palette", selected_palette)
		settingsFile.save(path)

# Sets the current color palette
func _set_colors(selected : int, available : Array) -> void:
	selected_palette = selected
	palettes = available
	emit_signal("colors_changed")

# Loads the settings to the setting menu instance when it 
# finishes loading
func _on_settings_menu_ready(settingsMenu : Control) -> void:
	settingsMenu.load_settings({
		"palette": selected_palette, 
		"mute": !sound_state
		})
	settingsMenu.set_theme(current_theme)
	settingsMenu.set_hooks(self, "_save_colors", "_save_sound", "_set_sound")

# Return the current sound state
func get_sound_state() -> bool:
	return sound_state

# Return the current color palette
func get_colors() -> PoolColorArray:
	return palettes[selected_palette]

# Return a Control node to show the settings menu
func get_settings_menu() -> Node:
	# Instance the scene
	var settingsMenu = settingsMenuScene.instance(
		PackedScene.GEN_EDIT_STATE_INSTANCE)
	# Connect the menu ready signal
	settingsMenu.connect(
		"menu_ready", self, "_on_settings_menu_ready", [], CONNECT_DEFERRED)
	# Request ready to be run when added to the tree
	settingsMenu.request_ready()
	return settingsMenu
