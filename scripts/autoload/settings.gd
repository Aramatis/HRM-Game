extends Node

# Signals

# Variables
var settings : ConfigFile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings = ConfigFile.new()
	var err = settings.load("user://settings.cfg")
	assert(err == OK)

# Give access to colors
func get_colors() -> PoolColorArray:
	var id = settings.get_value("graphics", "_pallete", 0)
	var colors = settings.get_value("graphics", "palletes", [null])[id]
	return PoolColorArray([colors["low"], colors["high"]])
