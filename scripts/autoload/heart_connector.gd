extends Node

class_name Heart_Connector
# TODO: Order functions and add docs 

# * Signals
signal provider_connected
signal scan_started(secs)
signal device_received(dev)
signal scan_finished
signal hrm_client_ready
signal connected_to_device
signal message_sent(msg)
signal hrm_tick(heart_rate)
signal heartbeat_error(err)

# * Variables
const HrmScene := preload("res://scenes/utilities/HRM Control.tscn")
var _server_pid: int
var _hrm_manager: Node
var _startup_timer: Timer
var _on_scan: bool
var _connected_to_provider: bool
var _saved_scan_time: int
var _detected_devices: Array

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start HRM server
	_saved_scan_time = 5
	_detected_devices = []
	_server_pid = OS.execute(".\\assets\\HRM.exe", [], false)
	_hrm_manager = HrmScene.instance()
	self.add_child(_hrm_manager)
	_startup_timer = Timer.new()
	self.add_child(_startup_timer)
	_startup_timer.connect("timeout", self, "_on_server_startup_timeout")
	# Connect HRM Manager signals
	_hrm_manager.connect(
		"connected_to_server", self, "_handle_server_connection"
	)
	_hrm_manager.connect("scan_requested", self, "_notify_scan_start")
	_hrm_manager.connect("scan_end", self, "_notify_scan_end")
	_hrm_manager.connect("auth_end", self, "_notify_device_connection")
	_hrm_manager.connect("incoming_enabled", self, "_notify_hrm_connection")
	_hrm_manager.connect("new_hr", self, "_hrm_tick")
	_hrm_manager.connect("vibration_sent", self, "_vibration_sent")
	_hrm_manager.connect("message_sent", self, "_notify_message_sent")
	_hrm_manager.connect("message_received", self, "_new_device")
	# Start timer
	_startup_timer.start(8)


# Kills the HRM process gracefully
func exit_gracefully() -> void:
	_hrm_manager._exit_gracefully()


# Register a node to receive scan updates
func register_scan(
	node: Node, start_method: String, end_method: String, device_method: String
) -> void:
	self.connect("scan_started", node, start_method)
	self.connect("scan_finished", node, end_method)
	self.connect("device_received", node, device_method)


# Register a node to receive band connection updates
func register_band_conn(
	node: Node, message_method: String, connected_method: String
) -> void:
	self.connect("connected_to_device", node, connected_method)
	self.connect("message_sent", node, message_method)


# Register a node to receive hrm updates
func register_hrm(
	node: Node, ready_method: String, tick_method: String, error_method: String
) -> void:
	self.connect("hrm_client_ready", node, ready_method)
	self.connect("hrm_tick", node, tick_method)
	self.connect("heartbeat_error", node, error_method)


# Selects the device listed on the index
func select_device(index: int) -> void:
	print("On select device call")
	_hrm_manager.connect_miband3(_detected_devices[index])


# Handles a new device message
func _new_device(dev: String) -> void:
	print("new device: %s" % dev)
	if not _detected_devices.has(dev):
		_detected_devices.append(dev)
		var dev_data = {
			"type": "MiBand 3", "uuid": dev, "id": _detected_devices.find(dev)
		}
		emit_signal("device_received", dev_data)


# Announces message requested
func _notify_message_sent(msg) -> void:
	emit_signal("message_sent", msg)


# Handles the confirmation of a sent vibration
func _vibration_sent(_ms) -> void:
	# TODO : Implement or delete
	pass


# Indicates that the connection server is ready
func _handle_server_connection() -> void:
	_connected_to_provider = true
	emit_signal("provider_connected")


# Announces device connection
func _notify_device_connection(result: bool) -> void:
	if result:
		emit_signal("connected_to_device")
		print("On connect msg call")
		_hrm_manager.message_miband3("Connected")


# Announces heart beat connection
func _notify_hrm_connection() -> void:
	emit_signal("hrm_client_ready")


# Requests a ble scan for devices
func request_scan(secs := 20) -> void:
	if _on_scan:
		# ! TODO: Add signal or remove
		return
	if ! _connected_to_provider:
		print("not connected to provider")
		_saved_scan_time = secs
		self.connect("provider_connected", self, "_start_scan")
		# In case the connection was made between the check and the connect()
		if _connected_to_provider:
			print("disconnecting signal 'cause bad sync")
			self.disconnect("provider_connected", self, "_start_scan")
		else:
			return
	_start_scan(secs)


# Starts a ble scan for devices
func _start_scan(secs := -1) -> void:
	print("start_scan, connection status: %s" % _connected_to_provider)
	if secs < 0:
		secs = _saved_scan_time
	_on_scan = true
	_detected_devices = []
	_hrm_manager.start_ble_scan(secs)


# Announces scan requested
func _notify_scan_start(secs) -> void:
	emit_signal("scan_started", secs)


# Handles an hrm tick received by the hrm manager
func _hrm_tick(hr: int) -> void:
	emit_signal("hrm_tick", hr)
	print("hrm tick received: %s" % hr)


# Handles a scan ending
func _notify_scan_end() -> void:
	_on_scan = false
	emit_signal("scan_finished")


# Delays the beginning of the program to allow the HRM Server to start
func _on_server_startup_timeout() -> void:
	print("On server startup timeout")
	_startup_timer.stop()
	_startup_timer.queue_free()
	_hrm_manager.start_connection()
