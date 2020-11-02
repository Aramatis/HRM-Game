class_name LevelController
extends Node

# * Signals
signal level_started
signal level_finished

# * Variables

const _FULL_ENTRY_TEMP = """Level {0} {1}:
	Valence at {1}: {2}
	Difficulty at {1}: {3}
	Target Difficulty: {4}
	Heart Rate at {1}: {5}"""
export (String) var level_name := "menu"
export (float) var total_time := 300.0
export (float) var readjust_time := 10.0
enum Actions { DIFF_UP, DIFF_DOWN, NONE }
var level_gui: LevelGui
var world_controller: WorldController
var valence_base: float
var current_valence: float
var local_difficulty_base: float
var current_difficulty: float
var local_difficulty_target: float
var _heart_rates: Array
var _diff_step: float
var _prev_action: int
var _valence_difficulty_effect: float
var _started: bool
var _end_timer: Timer

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_gui = $LevelGui
	world_controller = $World
	valence_base = 5.0
	current_valence = valence_base
	local_difficulty_base = 0.0
	current_difficulty = local_difficulty_base
	local_difficulty_target = 5.0
	_valence_difficulty_effect = 1.0
	_started = false
	_end_timer = $EndTimer
	_end_timer.set_wait_time(total_time)
	_prev_action = Actions.NONE
	_heart_rates = []
	var step_amount = total_time / readjust_time
	_diff_step = (local_difficulty_target - local_difficulty_base) / step_amount
	heart_connector.register_hrm(
		self, "_ignore_hrm_ready", "update_hr", "_handle_hrm_error"
	)
	level_gui.connect("bonus_used", self, "_use_bonus")
	level_gui.connect("valence_change", self, "_update_valence")


# Sets the initial values to start the level
func set_start(val_base: float, diff_base: float, diff_target: float) -> void:
	valence_base = val_base
	current_valence = valence_base
	local_difficulty_base = diff_base
	current_difficulty = local_difficulty_base
	local_difficulty_target = diff_target


# Adjust the difficulty on a valence
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


# Manages a bonus usage
func _use_bonus() -> void:
	world_controller.use_bonus()
	#! TODO: Continue


# Adjust the hr parameters
func update_hr(tick: int) -> void:
	var avg := 0.0
	for hr in _heart_rates:
		avg += hr
	avg /= _heart_rates.size()
	var percent_change = (tick * 1.0) - avg
	percent_change = (avg / 100) * percent_change
	_heart_rates.append(tick)
	if _heart_rates.size() > 5:
		_heart_rates.pop_front()
	if _started:
		pass
		#! TODO: Update children


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
	world_controller.update_difficulty()
	#! TODO: Continue


# Starts the level
func start() -> void:
	if not _started:
		_full_entry("start")
		_started = true
		emit_signal("level_started")
		_end_timer.start()


# Ends the level
func end() -> void:
	if _started:
		_started = false
		emit_signal("level_finished")
		_full_entry("finish")


# Logs an entry with all relevant values at the given moment
func _full_entry(moment: String) -> void:
	logger.log_entry(
		_FULL_ENTRY_TEMP.format(
			[
				level_name,
				moment,
				current_valence,
				current_difficulty,
				local_difficulty_target,
				_heart_rates.back()
			]
		)
	)
