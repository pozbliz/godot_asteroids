extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$UI.game_started.connect(_on_ui_game_started)
	$UI.open_main_menu()
	$Audio/AudioMainMenu.play()

func _process(delta: float) -> void:
	pass

func _input(event):
	if Input.is_action_just_pressed("open_menu"):
		var ui_state = $UI.get_current_state()
		if ui_state == $UI.UIState.GAMEPLAY:
			$UI.open_pause_menu()
		elif ui_state == $UI.UIState.PAUSE_MENU:
			$UI.start_game()
			
func _on_ui_game_started():
	play_game_music()
			
func play_main_menu_music():
	$Audio/AudioGameplay.stop()
	$Audio/AudioMainMenu.play()

func play_game_music():
	$Audio/AudioMainMenu.stop()
	$Audio/AudioGameplay.play()
