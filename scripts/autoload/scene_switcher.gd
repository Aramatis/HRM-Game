extends Node

# * Signals

# * Variables
var _timer: Timer
var _path: String
var _next_scene

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_path = ""
	_next_scene = null
	_timer = Timer.new()
	add_child(_timer)
	_timer.set_one_shot(true)
	_timer.set_wait_time(15.0)


# Preloads the scene in the given path
func preload_scene(path: String) -> void:
	_next_scene = ResourceLoader.load(path)
	_path = path


# Loads an already preloaded scene, returning the given path
func load_scene() -> String:
	call_deferred("_deferred_load")
	return _path


# Frees the current scene when it's safe
func _deferred_load() -> void:
	var _current_scene = get_tree().get_current_scene()
	_current_scene.free()
	var next_scene = _next_scene.instance()
	get_tree().set_current_scene(next_scene)
