extends Button

class_name Button_Id

# * Signals
signal pressed_id(id)

# * Variables
export var id: int setget set_id, get_id


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	id = 0


# Sets the button id
func set_id(new_id: int) -> void:
	id = new_id


# Returns the id saved
func get_id() -> int:
	return id


# Emits the custom signal
func _on_self_press() -> void:
	emit_signal("pressed_id", id)
