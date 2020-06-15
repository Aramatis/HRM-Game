extends Button

class_name Button_Id

# * Signals
# Thrown when the button is pressed
signal pressed_id(id)

# * Variables
# Id of the button
export var id: int setget set_id, get_id


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	id = 0


# Returns the id saved
func get_id() -> int:
	return id


# Sets the button id
func set_id(new_id: int) -> void:
	id = new_id


# Emits the custom signal on press
func _on_self_press() -> void:
	emit_signal("pressed_id", id)
