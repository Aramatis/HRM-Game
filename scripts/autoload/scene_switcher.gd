extends Node

# * Signals

# * Variables
const _path_prefix := "res://scenes/levels/%s"
var _timer: Timer
var _path: String
var _next_scene
var _next_state: Dictionary
var _path_list: PoolStringArray
var _path_number: int

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_path = ""
	_next_scene = null
	_timer = Timer.new()
	add_child(_timer)
	_timer.set_one_shot(true)
	_timer.set_wait_time(15.0)
	_path_list = [
		"pre_game/pre_game",
		"inward_outward/inward_outward",
		"color_runner/color_runner",
		"main_menu"
	]
	_path_number = 2
	_timer.connect("timeout", self, "_load_scene")


# Sets the scene change to start
func scene_change() -> void:
	_path = _path_prefix % _path_list[_path_number]
	_path_number += 1
	_path_number %= _path_list.size()
	_preload_scene()
	_timer.start()


# Preloads the scene in the given path
func _preload_scene() -> void:
	_next_scene = ResourceLoader.load(_path)


# Loads an already preloaded scene, returning the given path
func _load_scene() -> String:
	_next_state = _retrieve_state()
	call_deferred("_deferred_load")
	return _path


# Frees the current scene when it's safe
func _deferred_load() -> void:
	var _current_scene = get_tree().get_current_scene()
	# TODO: Retrieve state
	_current_scene.free()
	var next_scene = _next_scene.instance()
	get_tree().set_current_scene(next_scene)
	_load_previous_state(next_scene)


# Retrieves the state of the current scene
func _retrieve_state() -> Dictionary:
	# TODO: Implement, and remember to pause
	return {}


# Loads the saved state from a previous scene
func _load_previous_state(scene) -> void:
	# TODO: Implement
	pass
