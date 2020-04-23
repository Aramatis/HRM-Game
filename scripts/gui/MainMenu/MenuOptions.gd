extends VBoxContainer

# Signals

# Variables

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Quit the game
func _on_scan_pressed() -> void:
	get_tree().quit()

# Quit the game
func _on_start_pressed() -> void:
	get_tree().quit()

# Quit the game
func _on_settings_pressed() -> void:
	get_tree().quit()

# Quit the game
func _on_quit_pressed() -> void:
	get_tree().quit()
