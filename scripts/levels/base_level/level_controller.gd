class_name LevelController
extends Node

# * Signals
signal level_started
signal level_finished

# * Variables

# Template for an entry in the log
const _FULL_ENTRY_TEMP = """Level {0} {1}:
	Valence at {1}: {2}
	Difficulty at {1}: {3}
	Target Difficulty: {4}
	Heart Rate at {1}: {5}"""
# Name of the level
export (String) var level_name := "base"
# Total playtime of the level in seconds
export (float) var total_time := 300.0
# Time between adjustments of the level difficulty
export (float) var adjust_time := 10.0
# Base valence of the user when the level starts
export (float) var base_valence := 5.0
# Base difficulty of the level when it starts
export (float) var base_local_difficulty := 0.0
# Target difficulty for the level to achieve at its end
export (float) var target_local_difficulty := 5.0

enum Actions { DIFF_UP, DIFF_DOWN, NONE }
var current_valence: float
var current_difficulty: float
var level_gui: LevelGui
var _heart_rates: Array
var _diff_step: float
var _prev_action: int
var _valence_difficulty_effect: float
var _started: bool
var _paused: bool
var _end_timer: Timer
var _adjust_timer: Timer

# * Functions


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	level_gui = $LevelGui
	current_valence = base_valence
	current_difficulty = base_local_difficulty
	_valence_difficulty_effect = 1.0
	_started = false
	_paused = false
	_end_timer = $EndTimer
	_adjust_timer = $AdjustTimer
	_end_timer.set_wait_time(total_time)
	_adjust_timer.set_wait_time(adjust_time)
	_prev_action = Actions.NONE
	_heart_rates = []
	var step_amount = total_time / adjust_time
	_diff_step = (target_local_difficulty - base_local_difficulty) / step_amount
	heart_connector.register_hrm(
		self, "_ignore_hrm_ready", "update_hr", "_handle_hrm_error"
	)
	level_gui.connect("valence_change", self, "_update_valence")
	# Capture the user's mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Sets the initial values to start the level
func set_start(val_base: float, diff_base: float, diff_target: float) -> void:
	base_valence = val_base
	current_valence = base_valence
	base_local_difficulty = diff_base
	current_difficulty = base_local_difficulty
	target_local_difficulty = diff_target


# Adjust the difficulty on a valence change
func _update_valence(up: bool) -> void:
	var adjust = -1.0
	if up:
		adjust = 1.0
	match _prev_action:
		Actions.DIFF_UP:
			_valence_difficulty_effect += 0.1 * adjust
		Actions.DIFF_DOWN:
			_valence_difficulty_effect -= 0.1 * adjust
		_:
			pass


# Adjust the hr parameters
func update_hr(tick: int) -> void:
	_heart_rates.append(tick * 1.0)
	if _heart_rates.size() > 5:
		_heart_rates.pop_front()
		var avg := 0.0
		for hr in _heart_rates:
			avg += hr
		avg /= _heart_rates.size()
		get_tree().call_group("controllers", "hr_changed", avg)


# HRM error handler
func _handle_hrm_error(_err: int) -> void:
	pass


# HRM ready signal handler
func _ignore_hrm_ready() -> void:
	pass


# Adjusts the level difficulty according to a timer
func update_difficulty() -> void:
	var step = _diff_step * _valence_difficulty_effect
	if step > _diff_step:
		_prev_action = Actions.DIFF_UP
	elif step < _diff_step:
		_prev_action = Actions.DIFF_DOWN
	else:
		_prev_action = Actions.NONE
	current_difficulty += _diff_step * _valence_difficulty_effect
	get_tree().call_group(
		"controllers", "difficulty_updated", current_difficulty
	)


# Starts the level
func start() -> void:
	if not _started:
		_full_entry("start")
		_started = true
		emit_signal("level_started")
		_end_timer.start()
		_adjust_timer.start()


# Ends the level
func end() -> void:
	if _started:
		_started = false
		_full_entry("finish")
		emit_signal("level_finished")


# Logs an entry with all relevant values at the given moment
func _full_entry(moment: String) -> void:
	logger.log_entry(
		_FULL_ENTRY_TEMP.format(
			[
				level_name,
				moment,
				current_valence,
				current_difficulty,
				target_local_difficulty,
				_heart_rates.back()
			]
		)
	)


# Handles any level wide effects of the main action
func _on_main_pressed() -> void:
	if not _paused:
		get_tree().call_group("controllers", "main_used")


# Handles any level wide effects of the secondary action
func _on_secondary_pressed() -> void:
	if not _paused:
		get_tree().call_group("controllers", "secondary_used")


# Handles any level wide effects of a bonus press, raises the multiplier if a
# bonus can be used by default
func _on_bonus_pressed() -> void:
	if not _paused:
		var used = level_gui.apply_bonus()
		if used:
			get_tree().call_group("controllers", "bonus_used")
			level_gui.raise_multiplier()


# Handles the pausing of the level
func _on_pause_pressed() -> void:
	if _paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		level_gui.hide_pause()
		get_tree().paused = false
		_paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		level_gui.show_pause()
		get_tree().paused = true
		_paused = true


# Called when an input is given by the user
func _unhandled_input(event) -> void:
	if event.is_action_pressed("main_action"):
		_on_main_pressed()
	elif event.is_action_pressed("secondary_action"):
		_on_secondary_pressed()
	elif event.is_action_pressed("apply_bonus"):
		_on_bonus_pressed()
	elif event.is_action_pressed("ui_cancel"):
		_on_pause_pressed()
