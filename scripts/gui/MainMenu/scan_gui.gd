extends VBoxContainer

# * Signals
# Announces that a device has been selected and confirmed
signal device_ready

# * Variables
const Button_Id = preload("res://scenes/gui/button_id.tscn")
export var clock_waiting_message: String
export var clock_scan_message: String
export var request_title: String
export var request_subtitle: String
export var progress_title: String
export var progress_subtitle: String
export var done_title: String
export var done_subtitle: String
var _devices: Control
var _buttons: Control
var _clock: Control
var _clock_texture: TextureProgress
var _clock_text: Label
var _clock_tween: Tween

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_title_and_subtitle(request_title, request_subtitle)
	_clock = $Layout/Clock
	_clock_text = $Layout/Clock/About
	_set_clock_text(clock_waiting_message)
	_devices = $Layout/Devices
	_buttons = $Layout/Devices/Buttons
	_clock_texture = $Layout/Clock/TextureProgress
	_clock_tween = $ClockTween
	heart_connector.register_scan(
		self, "_real_scan_start", "_end_scan", "_add_device"
	)


# Starts a ble scan
func start_scan(secs := 20) -> void:
	_devices.hide()
	_set_title_and_subtitle(request_title, request_subtitle)
	_set_clock_text(clock_waiting_message)
	_clean_buttons()
	_clock.show()
	_clock_texture.set_value(0)
	_start_wait_tween()
	heart_connector.request_scan(secs)


# Shows the real progress of the scan
func _real_scan_start(secs) -> void:
	_stop_wait_tween()
	_set_title_and_subtitle(progress_title, progress_subtitle)
	_set_clock_text(clock_scan_message)
	print("tween duration: %s" % secs)
	_clock_tween.interpolate_property(_clock_texture, "value", 0, 360, secs)
	_clock_tween.start()
	_devices.show()


# Handles scan end
func _end_scan() -> void:
	_clock.hide()
	_clock_texture.set_value(0)
	_set_title_and_subtitle(done_title, done_subtitle)
	_enable_buttons()


# Removes all the device buttons
func _clean_buttons() -> void:
	for child in _buttons.get_children():
		_buttons.remove_child(child)
		child.queue_free()


# Enable device buttons
func _enable_buttons() -> void:
	for child in _buttons.get_children():
		child.set_disabled(false)


# Adds a new device button
func _add_device(dev) -> void:
	var button = _create_device_button(dev)
	_buttons.add_child(button)
	button.connect("pressed_id", self, "_select_device")


# Creates a button fron the received data
func _create_device_button(data: Dictionary) -> Node:
	var button = Button_Id.instance()
	button.set_text("MiBand 3: %s" % data["uuid"])
	button.set_id(data["id"])
	return button


# Handles device selection
func _select_device(id: int) -> void:
	heart_connector.select_device(id)
	print("Emitting device ready")
	emit_signal("device_ready")


# Sets the title and subtitle of this node
func _set_title_and_subtitle(title: String, subtitle: String) -> void:
	$Title.set_text(title)
	$Subtitle.set_text(subtitle)


# Sets the clock text
func _set_clock_text(text: String) -> void:
	_clock_text.set_text(text)


# Shows a waiting animation
func _start_wait_tween() -> void:
	_clock_texture.set_value(120)
	_clock_tween.interpolate_property(
		_clock_texture, "radial_initial_angle", 0, 360, 5
	)
	_clock_tween.set_repeat(true)
	_clock_tween.start()


# Stops the waiting animation
func _stop_wait_tween() -> void:
	_clock_tween.set_repeat(false)
	_clock_tween.stop_all()
	_clock_texture.set_value(0)
	_clock_texture.set_radial_initial_angle(0)
