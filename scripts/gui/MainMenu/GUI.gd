extends Control


###### Signals ######

# Thrown to request start of the game
signal startGame
# Thrown to request exit from the game 
signal exitGame


###### Variables ######

# The texture to display in the panel when it's hidden
var hiddenTexture = preload("res://assets/textures/transparent.png")
# The texture to display in the panel when it's shown
var panelTexture = preload("res://assets/textures/panel.png")
# The panel node
var panel : NinePatchRect
# The margins on the menu, to be restored after displaying the settings
var menuMargins : Array
# The non-panel gui nodes
var nonPanelNodes : Array


###### Functions ######

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sets the focus to the scan button by default
	$Menu/MenuOptions/Scan.grab_focus()
	panel = $Menu/Separator
	nonPanelNodes = $Menu.get_children()
	nonPanelNodes.erase(panel)
	menuMargins = []
	_save_margins()

# Saves the current menu margins to a variable
func _save_margins() -> void:
	for margin in range(0, 4):
		menuMargins.append($Menu.get_margin(margin))

# Loads the menu margins from a variable
func _load_margins(margins : Array) -> void:
	for margin in range(0, 4):
		$Menu.set_margin(margin, margins[margin])

# Removes all the children added to the panel
# contents and hides the panel
func clean_panel() -> void:
	var contentContainer = panel.get_child(0)
	for child in contentContainer.get_children():
		contentContainer.remove_child(child)
		child.queue_free()
	_hide_panel()

# Adds the given content to the panel
func _add_content(content : Node) -> void:
	var contentContainer = panel.get_child(0)
	contentContainer.add_child(content)

# Hides the non-panel gui nodes
func _hide_extras() -> void:
	for node in nonPanelNodes:
		node.hide()

# Shows the non-panel gui nodes
func _show_extras() -> void:
	for node in nonPanelNodes:
		node.show()

# Hides the panel border
func _hide_panel() -> void:
	panel.set_texture(hiddenTexture)

# Shows the panel border
func _show_panel() -> void:
	panel.set_texture(panelTexture)

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
	clean_panel()
	_load_margins(menuMargins)
	_show_extras()

# Sends a signal to start the game
func _start_game() -> void:
	emit_signal("startGame")

# Sends a signal to exit the game
func _exit_game() -> void:
	emit_signal("exitGame")
