extends LevelController

# * Signals

# * Variables

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$World/PlayerController.connect("damaged", self, "_damaged")
	$World/PlayerController.connect("healed", self, "_healed")
	level_gui.set_active(true)


# Handles any level wide effects of the secondary action
func _on_secondary_pressed() -> void:
	level_gui.lower_multiplier()
	._on_secondary_pressed()


# Lowers the multiplier when a ball is damaged
func _damaged() -> void:
	level_gui.lower_multiplier()


# Raises the multiplier when a ball is healed
func _healed() -> void:
	level_gui.raise_multiplier()
