extends Controller

# * Signals
signal damaged
signal healed

# * Variables
var _rail_system: RailSystem

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rail_system = $RailSystem


# Called when the main action is used, reverts the movement directions
func main_used() -> void:
	_rail_system.toggle_direction()


# Called when the secondary action is used, removes a rail if possible
func secondary_used() -> void:
	_rail_system.remove_rail()


# Called when a bonus is used, adds a rail
func bonus_used() -> void:
	var rail = _rail_system.add_rail()
	rail.connect("ball_hit", self, "_get_damaged")
	rail.connect("ball_enabled", self, "_get_healed")


# Emits the damaged signal
func _get_damaged() -> void:
	emit_signal("damaged")


# Emits the healed signal
func _get_healed() -> void:
	emit_signal("healed")
