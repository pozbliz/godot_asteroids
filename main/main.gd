extends Node


@export var asteroid_scene: PackedScene
@export var asteroid_small_scene: PackedScene


var score: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	$UI.game_started.connect(_on_ui_game_started)
	$UI.open_main_menu()
	$Audio/AudioMainMenu.play()
	
	$AsteroidTimer.timeout.connect(_on_asteroid_timer_timeout)
	$Player.player_died.connect(_on_player_died)

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
	get_tree().paused = false
	for asteroid in get_tree().get_nodes_in_group("asteroids"):
		if is_instance_valid(asteroid):
			asteroid.queue_free()
	score = 0
	$UI/HUD.update_score(score)
	$Player.reset_player()
	$Player.position = $PlayerStartPosition.position
	$AsteroidTimer.start()
	play_game_music()
	
func play_main_menu_music():
	$Audio/AudioGameplay.stop()
	$Audio/AudioMainMenu.play()
	
func play_game_music():
	$Audio/AudioMainMenu.stop()
	$Audio/AudioGameplay.play()
	
func _on_asteroid_timer_timeout():
	var asteroid: Asteroid
	if randf() < 0.5:
		asteroid = create_asteroid()
	else:
		asteroid = create_small_asteroid()
	var asteroid_spawn_location = $AsteroidPath/AsteroidSpawnLocation
	asteroid_spawn_location.progress_ratio = randf()
	asteroid.position = asteroid_spawn_location.position
	
	var angle = asteroid_spawn_location.rotation + PI / 2 + randf_range(-PI / 4, PI / 4)
	var dir = Vector2(cos(angle), sin(angle)).normalized()
	asteroid.setup(dir)
	
func create_asteroid() -> Asteroid:
	var asteroid = asteroid_scene.instantiate()
	add_child(asteroid)
	asteroid.player_hit.connect(_on_player_hit)
	asteroid.asteroid_hit.connect(_on_asteroid_hit)
	asteroid.rescale(randf_range(3.0, 6.0))
	asteroid.points = 2
	asteroid.damage = 1
	
	return asteroid
	
func create_small_asteroid() -> Asteroid:
	var asteroid = asteroid_small_scene.instantiate()
	add_child(asteroid)
	asteroid.player_hit.connect(_on_player_hit)
	asteroid.asteroid_hit.connect(_on_asteroid_hit)
	asteroid.rescale(randf_range(1.5, 2.5))
	asteroid.points = 1
	asteroid.damage = 1
	
	return asteroid
	
func _on_player_hit(damage: int):
	$Player.take_damage(damage)
	
func _on_player_died():
	game_over()
	
func game_over():
	get_tree().paused = true
	await $UI/HUD.show_game_over()
	$UI.open_main_menu()
	play_main_menu_music()
	
func _on_asteroid_hit(points: int, position: Vector2, direction: Vector2):
	# split asteroid into smaller pieces
	score += points
	$UI/HUD.update_score(score)
	
	if points > 1:
		split_asteroid(position, direction)
	
func split_asteroid(position: Vector2, direction: Vector2):
	var angle_offset1 = randf_range(-PI / 6, PI / 6)
	var angle_offset2 = randf_range(-PI / 6, PI / 6)
	
	var dir1 = direction.rotated(angle_offset1)
	var dir2 = direction.rotated(angle_offset2)
	
	var asteroid1 = create_small_asteroid()
	asteroid1.position = position
	asteroid1.default_speed = 100
	asteroid1.setup(dir1, asteroid1.default_speed)
	
	var asteroid2 = create_small_asteroid()
	asteroid2.position = position
	asteroid2.default_speed = 100
	asteroid2.setup(dir2, asteroid2.default_speed)
