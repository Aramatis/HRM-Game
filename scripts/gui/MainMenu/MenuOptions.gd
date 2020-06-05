extends VBoxContainer


###### Signals ######

# Thrown when the settings menu button is pressed
signal showSettings
# Thrown when the scan for miband button is pressd
signal showScan
# Thrown when the start game button is pressed
signal startGame
# Thrown when the quit button is pressed
signal quitGame


###### Functions ######

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Gives focus to buttons when requested
func _on_button_hovered(btn : Button) -> void:
	btn.grab_focus()

# Sends a signal to start a scan for MiBand devices
func _on_scan_pressed() -> void:
	emit_signal("showScan")

# Start the game
func _on_start_pressed() -> void:
	emit_signal("startGame")

# Show the settings
func _on_settings_pressed() -> void:
	emit_signal("showSettings")

# Quit the game
func _on_quit_pressed() -> void:
	emit_signal("quitGame")
