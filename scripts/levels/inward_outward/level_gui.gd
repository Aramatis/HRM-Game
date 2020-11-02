tool
class_name LevelGui
extends Control

# * Signals
# Signals a valence change. Is true if valence is up.
signal valence_change(up)
# Signals the use of a bonus
signal bonus_used

# * Variables
enum Corners { UPPER_LEFT, UPPER_RIGHT, LOWER_LEFT, LOWER_RIGHT }
enum Edges { LEFT, RIGHT, TOP, BOTTOM }
var _slider: Control
var _bonus: Control
var _score: Control
var _current_multiplier: int
var active := false setget set_active, get_active

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_slider = $AffectiveSlider
	_bonus = $BonusGui
	_score = $ScorePanel
	_current_multiplier = 1
	_slider.connect("valence_increased", self, "valence_up")
	_slider.connect("valence_decreased", self, "valence_down")
	_bonus.connect("bonus_used", self, "_propagate_bonus")


# Handles a valence increase
func valence_up() -> void:
	emit_signal("valence_change", true)
	_bonus.load_bonus()


# Handles a valence decrease
func valence_down() -> void:
	emit_signal("valence_change", false)
	_bonus.load_bonus()


# Attempts to use a bonus
func activate_bonus() -> void:
	_bonus.use_bonus()


# Sets the variable active to the given value
func set_active(on: bool) -> void:
	active = on
	_score.set_active(on)


# Returns the value of the variable active
func get_active() -> bool:
	return active


# Propagates the bonus_used signal
func _propagate_bonus() -> void:
	emit_signal("bonus_used")


# Raises the current multiplier
func raise_multiplier() -> void:
	_current_multiplier += 1
	if _current_multiplier > 1:
		_score.raise_multiplier()


# Lowers the current multiplier
func lower_multiplier() -> void:
	if _current_multiplier > 1:
		_score.lower_multiplier()
	_current_multiplier -= 1
