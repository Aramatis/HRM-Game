extends Control

# Signals
signal valence_up
signal valence_down

# Variables
export var lowColor : Color setget change_lower_color
export var highColor : Color setget change_higher_color
export var vertical = false setget set_vertical
export var inputSampleDelay : float
var accDelta : float
var grad : Gradient
var vLight : Light2D
var hLight : Light2D
var slider : Slider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	accDelta = 0.0
	grad = $GradSprite.texture.gradient
	slider = $Slider
	hLight = $GradSprite/HLight
	vLight = $GradSprite/VLight
	_apply_colors()

# Apply the currently selected colors
func _apply_colors() -> void:
	if grad != null:
		grad.set_color(0, lowColor)
		grad.set_color(2, highColor)

# Change the color representing lower valence
func change_lower_color(color : Color):
	lowColor = color
	_apply_colors()

# Change the color representing higher valence
func change_higher_color(color : Color):
	highColor = color
	_apply_colors()

# Change both colors representing valence
func change_colors(low : Color, high : Color):
	lowColor = low
	highColor = high
	_apply_colors()

# Set the scale keeping aspect ratio
func scale(scale : float) -> void:
	set_scale(Vector2(scale, scale))

# Rotate the control to or from vertical position
func set_vertical(vert : bool) -> void:
	if vertical != vert:
		if vert:
			hLight.set_enabled(false)
			set_rotation_degrees(-90)
			vLight.set_enabled(true)
		else:
			vLight.set_enabled(false)
			set_rotation_degrees(0)
			hLight.set_enabled(true)
		vertical = vert

# Override from native function to allow for positioning by center
func set_position(pos : Vector2, center := true) -> void:
	if center:
		var current_size = get_size()
		pos[0] -= (current_size[0] / 2)
		pos[1] -= (current_size[1] / 2)
	.set_position(pos)

# Receives valence input
func _process(delta : float) -> void:
	accDelta += delta
	if accDelta >= inputSampleDelay:
		if Input.is_action_pressed("ui_valence_up"):
			slider.value += 1
			emit_signal("valence_up")
			accDelta = 0.0
		if Input.is_action_pressed("ui_valence_down"):
			slider.value -= 1
			emit_signal("valence_down")
			accDelta = 0.0
