extends HBoxContainer


###### Variables ######

# The name of the palette
export var PaletteName := "Standard" \
	setget set_palette_name, get_palette_name
# The color representing the relaxed state
export var RelaxedColor := Color(0, 0, 1.0) \
	setget set_relaxed_color, get_relaxed_color
# The color representing the hyped state
export var HypedColor := Color(1.0, 0, 0) \
	setget set_hyped_color, get_hyped_color


###### Functions ######

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Sets the palette name to the given string
func set_palette_name(name : String) -> void:
	PaletteName = name
	$Name.set_text(name)

# Sets the palette relaxed color to the given color
func set_relaxed_color(color : Color) -> void:
	RelaxedColor = color
	$Color1/Color.set_frame_color(color)

# Sets the palette hyped color to the given color
func set_hyped_color(color : Color) -> void:
	HypedColor = color
	$Color2/Color.set_frame_color(color)

# Returns the palette name
func get_palette_name() -> String:
	return PaletteName

# Returns the palette relaxed color
func get_relaxed_color() -> Color:
	return RelaxedColor

# Returns the palette hyped color
func get_hyped_color() -> Color:
	return HypedColor

# Returns an array with the colors of the palette, hyped first
func get_colors() -> PoolColorArray:
	var color_array = PoolColorArray()
	color_array.append(HypedColor)
	color_array.append(RelaxedColor)
	return color_array
