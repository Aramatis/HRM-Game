class_name Controller
extends Node2D

# * Signals

# * Variables
var _last_avg_hr: float
var _last_difficulty: float

# * Functions


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	_last_avg_hr = 0.0
	_last_difficulty = 0.0
	add_to_group("controllers")


# Called when the difficulty is updated and should be overridden. By default
# only saves the new difficulty
func difficulty_updated(new_diff: float) -> void:
	_last_difficulty = new_diff


# Returns the current difficulty
func get_difficulty() -> float:
	return _last_difficulty


# Called when the average hr is updated and should be overridden. By default
# only saves the new average hr
func hr_changed(new_avg_hr: float) -> void:
	_last_avg_hr = new_avg_hr


# Returns the current heart rate
func get_avg_hr() -> float:
	return _last_avg_hr


# Called when the main action is used and should be overridden. By default it
# does nothing
func main_used() -> void:
	pass


# Called when the secondary action is used and should be overridden. By default
# it does nothing
func secondary_used() -> void:
	pass


# Called when a bonus is used and should be overridden. By default it does
# nothing
func bonus_used() -> void:
	pass
