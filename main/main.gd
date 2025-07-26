extends Node


@export var asteroid_scene: PackedScene


var score: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$UI.game_started.connect(_on_ui_game_started)
	$UI.open_main_menu()
	$Audio/AudioMainMenu.play()
	
	$AsteroidTimer.timeout.connect(_on_asteroid_timer_timeout)

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
	$Player.position = $PlayerStartPosition.position
	score = 0
	
func play_main_menu_music():
	$Audio/AudioGameplay.stop()
	$Audio/AudioMainMenu.play()
	
func play_game_music():
	$Audio/AudioMainMenu.stop()
	$Audio/AudioGameplay.play()
	
func _on_asteroid_timer_timeout():
	create_asteroid()
	
func create_asteroid():
	var asteroid = asteroid_scene.instantiate()
	add_child(asteroid)
	asteroid.player_hit.connect(_on_player_hit)
	asteroid.asteroid_hit.connect(_on_asteroid_hit)
	
func _on_player_hit():
	game_over()
	
func game_over():
	await $UI.show_message("Game Over")
	$UI.open_main_menu()
	play_main_menu_music()
	
func _on_asteroid_hit():
	# split asteroid into smaller pieces
	pass
