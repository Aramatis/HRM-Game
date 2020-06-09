extends Control

# * Signals

# Thrown to request start of the game
signal start_requested
# Thrown to request exit from the game 
signal exit_requested

# * Constants

# The texture to display in the panel when it's hidden
const HiddenTexture: StreamTexture = \
		preload("res://assets/textures/transparent.png")
# The texture to display in the panel when it's shown
const PanelTexture: StreamTexture = preload("res://assets/textures/panel.png")

# * Variables

# The panel node
var _panel: NinePatchRect
# The margins on the menu, to be restored after displaying the settings
var _menu_margins: Array
# The non-panel gui nodes
var _non_panel_nodes: Array

# * Functions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sets the focus to the scan button by default
	$Menu/MenuOptions/Scan.grab_focus()
	_panel = $Menu/Separator
	_non_panel_nodes = $Menu.get_children()
	_non_panel_nodes.erase(_panel)
	_menu_margins = []
	_save_margins()


# Removes all the children added to the panel
# contents and hides the panel
func _clean_panel() -> void:
	var content_container = _panel.get_child(0)
	for child in content_container.get_children():
		content_container.remove_child(child)
		child.queue_free()
	_hide_panel()


# Saves the current menu margins to a variable
func _save_margins() -> void:
	for margin in range(0, 4):
		_menu_margins.append($Menu.get_margin(margin))


# Loads the menu margins from a variable
func _load_margins(margins: Array) -> void:
	for margin in range(0, 4):
		$Menu.set_margin(margin, margins[margin])


# Adds the given content to the panel
func _add_content(content: Node) -> void:
	var content_container = _panel.get_child(0)
	content_container.add_child(content)


# Hides the non-panel gui nodes
func _hide_extras() -> void:
	for node in _non_panel_nodes:
		node.hide()


# Shows the non-panel gui nodes
func _show_extras() -> void:
	for node in _non_panel_nodes:
		node.show()


# Hides the panel border
func _hide_panel() -> void:
	_panel.set_texture(HiddenTexture)


# Shows the panel border
func _show_panel() -> void:
	_panel.set_texture(PanelTexture)


# Shows the scan dialog
func _show_scan() -> void:
	# TODO: Implement 
	pass


# Shows the settings menu
func _show_settings() -> void:
	# Requests a settings node
	var menu = settings.get_settings_menu()
	# Hide non-panel nodes
	_hide_extras()
	_load_margins([20, 20, -20, -20])
	_add_content(menu)
	# Show the settings in the panel
	menu.set_return_name("Main Menu")
	menu.set_return_hook(self, "_hide_settings")
	_show_panel()


# Hides the settings menu
func _hide_settings() -> void:
	_clean_panel()
	_load_margins(_menu_margins)
	_show_extras()


# Sends a signal to start the game
func _start_game() -> void:
	emit_signal("start_requested")


# Sends a signal to exit the game
func _quit_game() -> void:
	emit_signal("exit_requested")
