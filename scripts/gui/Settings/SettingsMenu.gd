extends VBoxContainer


###### Signals ######

# Thrown when the back button is pressed 
signal exit_menu
# Thrown when a color palette change is saved to file 
signal colors_changed(palette_n)
# Thrown when a sound change is saved
signal sound_saved(on)
# Thrown when the mute toggle is changed
signal sound_changed(on)
# Thrown when the menu is ready to be used
signal menu_ready(menu)


###### Variables ######

# Text of the back button
export var backText := "Back"
# Color palette manager node
var palettes : HBoxContainer
# Mute sound manager node
var mute : HBoxContainer
# Back button node
var backButton : Button
# Save button node
var saveButton : Button
# Current loaded palette fron file
var loaded_palette : int
# Current loaded mute value from file
var loaded_mute : bool


###### Functions ######

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	palettes = $"Config/Color Palettes"
	mute = $Config/Mute
	backButton = $Back/BackContainer/BackButton
	saveButton = $Back/SaveContainer/SaveButton
	_set_back_text("  " + backText + "  ")
	emit_signal("menu_ready", self)

# Notifies the exiting of this menu
func _exit_menu() -> void:
	# Restore the mute setting if its change wasn't saved
	mute.restore_saved()
	# Notifies the menu exiting
	emit_signal("exit_menu")

# Propagates the sound_changed signal up
func propagate_sound_change(on : bool) -> void:
	emit_signal("sound_changed", on)

# Saves changed settings on save button press
func _save_changes() -> void:
	if mute.get_muted() != loaded_mute:
		loaded_mute = mute.get_muted()
		emit_signal("sound_saved", !loaded_mute)
	if palettes.get_selected() != loaded_palette:
		loaded_palette = palettes.get_selected()
		emit_signal("colors_changed", loaded_palette)

# Sets the text on the back button
func _set_back_text(text : String) -> void:
	backButton.set_text("  " + text + "  ")

# Sets the text on the back button to be "Back to <previous interface>" 
func set_return_name(name : String) -> void:
	_set_back_text("Back to " + name)

# Sets the hook for the exit signal
func set_return_hook(node : Node, method : String) -> void:
	self.connect("exit_menu", node, method)

# Loads settings saved in the config file, given through a dict
func load_settings(config : Dictionary) -> void:
	for key in config.keys():
		match key:
			# Load the selected palette
			"palette":
				loaded_palette = config[key]
				palettes.load_palettes(config[key], true)
			# Load the mute configuration
			"mute":
				loaded_mute = config[key]
				mute.load_muted(config[key], true)
			# Omit any extra variables
			_:
				print("Key %s not implemented in settings menu." % str(key))

# Sets hooks to the settings manager, so it receives any updates
func set_hooks(settings_node : Node, save_colors : String, save_sound : String, set_sound : String) -> void:
	self.connect("colors_changed", settings_node, save_colors)
	self.connect("sound_saved", settings_node, save_sound)
	self.connect("sound_changed", settings_node, set_sound)

# Sets the given theme to be used on this menu
func set_theme(theme : Theme) -> void:
	# TODO: IMPLEMENT
	pass

# Give focus to a button on its request
func _request_focus(btn : Button) -> void:
	btn.grab_focus()
