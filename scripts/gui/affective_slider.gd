extends Control

# * Signals

# Thrown when a drop in valence is indicated
signal valence_decreased
# Thrown when a rise in valence is indicated
signal valence_increased

# * Variables

# True if this affective slider is in vertical position
export var vertical = false setget set_vertical
# Time to wait between inputs to be valid
export var input_sample_delay: float
# Accumulated time between inputs
var _acc_delta: float
# Color that represents high valence
# Gradient of this slider
var _grad: Gradient
# Light mask for the vertical position
var _high_color: Color setget change_higher_color
# Color that represents low valence
var _low_color: Color setget change_lower_color
# Light mask for the horizontal position
var _h_light: Light2D
# Light mask for the vertical position
var _v_light: Light2D
# Internal slider for the current valence of the user
var _slider: Slider

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_acc_delta = 0.0
	_grad = $GradSprite.texture.gradient
	_slider = $Slider
	_h_light = $GradSprite/HLight
	_v_light = $GradSprite/VLight
	settings.request_color_updates(self, "update_colors")
	update_colors()


# Receives valence input
func _process(delta: float) -> void:
	_acc_delta += delta
	if _acc_delta >= input_sample_delay:
		if Input.is_action_pressed("ui_valence_up"):
			_slider.value += 1
			emit_signal("valence_increased")
			_acc_delta = 0.0
		if Input.is_action_pressed("ui_valence_down"):
			_slider.value -= 1
			emit_signal("valence_decreased")
			_acc_delta = 0.0


# Change both colors representing valence
func change_colors(low: Color, high: Color):
	_low_color = low
	_high_color = high
	_apply_colors()


# Change the color representing higher valence
func change_higher_color(color: Color):
	_high_color = color
	_apply_colors()


# Change the color representing lower valence
func change_lower_color(color: Color):
	_low_color = color
	_apply_colors()


# Set the scale keeping aspect ratio
func scale(scale: float) -> void:
	set_scale(Vector2(scale, scale))


# Override from native function to allow for positioning by center point
func set_position(pos: Vector2, center := true) -> void:
	if center:
		var current_size = get_size()
		pos[0] -= (current_size[0] / 2)
		pos[1] -= (current_size[1] / 2)
	.set_position(pos)


# Rotate the control to or from vertical position
func set_vertical(vert: bool) -> void:
	if vertical != vert:
		if vert:
			_h_light.set_enabled(false)
			set_rotation_degrees(-90)
			_v_light.set_enabled(true)
		else:
			_v_light.set_enabled(false)
			set_rotation_degrees(0)
			_h_light.set_enabled(true)
		vertical = vert


# Updates the colors according to the current colors in settings
func update_colors() -> void:
	var _new_colors = settings.get_colors()
	change_colors(_new_colors[0], _new_colors[1])


# Apply the currently selected colors
func _apply_colors() -> void:
	if _grad != null:
		_grad.set_color(0, _low_color)
		_grad.set_color(2, _high_color)
