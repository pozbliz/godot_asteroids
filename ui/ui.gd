extends CanvasLayer


enum UIState { MAIN_MENU, PAUSE_MENU, OPTIONS_MENU, GAMEPLAY }

var current_state: UIState = UIState.MAIN_MENU

signal game_started


func _ready() -> void:
	$MainMenu/MarginContainer/VBoxContainer/StartGameButton.pressed.connect(_on_start_game_button_pressed)
	$MainMenu/MarginContainer/VBoxContainer/OptionsButton.pressed.connect(_on_options_button_pressed)
	$MainMenu/MarginContainer/VBoxContainer/ExitGameButton.pressed.connect(_on_exit_game_button_pressed)
	
	$PauseMenu/MarginContainer/VBoxContainer/ResumeGameButton.pressed.connect(_on_resume_game_button_pressed)
	$PauseMenu/MarginContainer/VBoxContainer/NewGameButton.pressed.connect(_on_start_game_button_pressed)
	$PauseMenu/MarginContainer/VBoxContainer/OptionsButton.pressed.connect(_on_options_button_pressed)
	$PauseMenu/MarginContainer/VBoxContainer/ExitGameButton.pressed.connect(_on_exit_game_button_pressed)
	
	$PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	

func _process(delta: float) -> void:
	pass
	
func _gui_input(event):
	if event.is_action_pressed("ui_up"):
		print("Inventory cursor moves up")
		event.consume()
	elif event.is_action_pressed("ui_down"):
		print("Inventory cursor moves down")
		event.consume()
		
func _on_start_game_button_pressed():
	start_game()
	
func _on_resume_game_button_pressed():
	start_game()
	
func _on_options_button_pressed():
	open_options_menu()
	
func _on_exit_game_button_pressed():
	get_tree().quit()
	
func open_main_menu():
	current_state = UIState.MAIN_MENU
	$MainMenu.show()
	$PauseMenu.hide()
	$OptionsMenu.hide()
	$HUD.hide()
	get_tree().paused = true
	
	$MainMenu/MarginContainer/VBoxContainer/StartGameButton.grab_focus()

func open_pause_menu():
	current_state = UIState.PAUSE_MENU
	$MainMenu.hide()
	$PauseMenu.show()
	$OptionsMenu.hide()
	$HUD.show()
	get_tree().paused = true
	
	$PauseMenu/MarginContainer/VBoxContainer/ResumeGameButton.grab_focus()

func open_options_menu():
	current_state = UIState.OPTIONS_MENU
	$MainMenu.hide()
	$PauseMenu.hide()
	$OptionsMenu.show()
	$HUD.hide()
	get_tree().paused = true

func start_game():
	current_state = UIState.GAMEPLAY
	$MainMenu.hide()
	$PauseMenu.hide()
	$OptionsMenu.hide()
	$HUD.show()
	get_tree().paused = false
	game_started.emit()
	
func get_current_state() -> UIState:
	return current_state
	
func is_game_running() -> bool:
	return $HUD.visible and not $MainMenu.visible and not $PauseMenu.visible and not $OptionsMenu.visible
	
func show_message(text):
	$HUD/MessageLabel.text = text
	$HUD/MessageLabel.show()
	$HUD/MessageTimer.start()
