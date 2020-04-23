extends Control

# Signals

# Variables

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Menu/MenuOptions/Scan.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
