extends Control


###### Signals ######

# Thrown when a rise in valence is indicated
signal valence_up
# Thrown when a drop in valence is indicated
signal valence_down


###### Variables ######

# Color that represents low valence
var lowColor : Color setget change_lower_color
# Color that represents high valence
var highColor : Color setget change_higher_color
# True if this affective slider is in vertical position
export var vertical = false setget set_vertical
# Time to wait between inputs to be valid
export var inputSampleDelay : float
# Accumulated time between inputs
var accDelta : float
# Gradient of this slider
var grad : Gradient
# Light mask for the vertical position
var vLight : Light2D
# Light mask for the horizontal position
var hLight : Light2D
# Internal slider for the current valence of the user
var slider : Slider


###### Functions ######

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	accDelta = 0.0
	grad = $GradSprite.texture.gradient
	slider = $Slider
	hLight = $GradSprite/HLight
	vLight = $GradSprite/VLight
	settings.request_color_updates(self, "update_colors")
	update_colors()

# Updates the colors according to the current colors in settings
func update_colors() -> void:
	var newColors = settings.get_colors()
	change_colors(newColors[0], newColors[1])

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

# Override from native function to allow for positioning by center point
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
