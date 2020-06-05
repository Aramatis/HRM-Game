extends Node


###### Functions ######

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Handles the game start signal
func start_game() -> void:
	pass # TODO: Implement

# Handles the game exit signal
func exit_game() -> void:
	get_tree().quit()
