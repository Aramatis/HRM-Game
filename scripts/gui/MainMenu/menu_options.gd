extends VBoxContainer

# * Signals

# Thrown when the settings menu button is pressed
signal settings_pressed
# Thrown when the scan for miband button is pressd
signal scan_pressed
# Thrown when the start game button is pressed
signal start_pressed
# Thrown when the quit button is pressed
signal quit_pressed

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Hides the scan button
func hide_scan() -> void:
	$Scan.hide()


# Shows the start button
func show_start() -> void:
	$Start.show()


# Gives focus to buttons when requested
func _on_button_hovered(btn: Button) -> void:
	btn.grab_focus()


# Sends a signal to start a scan for MiBand devices
func _on_scan_pressed() -> void:
	emit_signal("scan_pressed")


# Start the game
func _on_start_pressed() -> void:
	emit_signal("start_pressed")


# Show the settings
func _on_settings_pressed() -> void:
	emit_signal("settings_pressed")


# Quit the game
func _on_quit_pressed() -> void:
	emit_signal("quit_pressed")
