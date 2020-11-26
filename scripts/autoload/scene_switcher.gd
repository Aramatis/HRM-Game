extends Node

# * Signals

# * Variables
const _path_prefix := "res://scenes/levels/%s"
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
	#! TODO: Update _path_list and _path_number
	_path_list = [
		"pre_game/pre_game",
		"inward_outward/inward_outward",
		"color_runner/color_runner",
		"main_menu"
	]
	_path_number = 2


# Sets the scene change to start
func scene_change() -> void:
	_path = _path_prefix % _path_list[_path_number]
	_path_number += 1
	_path_number %= _path_list.size()
	_preload_scene()
	_load_scene()


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
	_current_scene.free()
	var next_scene = _next_scene.instance()
	get_tree().set_current_scene(next_scene)
	_load_previous_state(next_scene)
	next_scene.connect(
		"level_finished", self, "scene_change", [], Object.CONNECT_ONESHOT
	)
	next_scene.start()


# Retrieves the state of the current scene
func _retrieve_state() -> Dictionary:
	var _current_scene = get_tree().get_current_scene()
	var state = _current_scene.retrieve_data()
	var result = {}
	if not state.empty():
		result["current_val"] = state["current_val"]
		var diff_raise = state["current_diff"] - state["base_diff"]
		var target_raise = state["target_diff"] - state["base_diff"]
		var raise_achieved = diff_raise / target_raise
		result["base_diff"] = state["current_diff"] - (diff_raise / 3)
		result["target_diff"] = (
			result["base_diff"]
			+ (target_raise * raise_achieved * 1.1)
		)
		result["current_hr"] = state["current_hr"]
	return result


# Loads the saved state from a previous scene
func _load_previous_state(scene) -> void:
	if not _next_state.empty():
		scene.set_start(_next_state)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#! TODO: Implement
	#if _next_scene is null:
	#	scene_change()
	pass
