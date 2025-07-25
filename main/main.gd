extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$UI.open_main_menu

func _process(delta: float) -> void:
	pass

func _input(event):
	if Input.is_action_just_pressed("open_menu"):
		var ui_state = $UI.get_current_state()
		if ui_state == $UI.UIState.GAMEPLAY:
			$UI.open_pause_menu()
		elif ui_state == $UI.UIState.PAUSE_MENU:
			$UI.start_game()
