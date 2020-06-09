extends Button

# * Signals

# Thrown when the button is hovered, with itself as btn
signal hovered(btn)

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("mouse_entered", self, "ask_focus")


# When this button is hovered, asks to be focused
func ask_focus() -> void:
	emit_signal("hovered", self)
