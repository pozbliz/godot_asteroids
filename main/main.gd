extends Node


@export var asteroid_scene: PackedScene
@export var big_asteroid_config: AsteroidConfig
@export var small_asteroid_config: AsteroidConfig


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
			$UI.resume_game()
			
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
	var is_big = randf() < 0.5
	var config = big_asteroid_config if is_big else small_asteroid_config
	spawn_asteroid(config)

func spawn_asteroid(config: AsteroidConfig):
	var asteroid: Asteroid = asteroid_scene.instantiate()
	add_child(asteroid)

	asteroid.player_hit.connect(_on_player_hit)
	asteroid.asteroid_hit.connect(_on_asteroid_hit)
	var spawn_location = $AsteroidPath/AsteroidSpawnLocation
	spawn_location.progress_ratio = randf()
	asteroid.position = spawn_location.position

	var angle = spawn_location.rotation + PI / 2 + randf_range(-PI / 4, PI / 4)
	var dir = Vector2(cos(angle), sin(angle)).normalized()

	asteroid.setup(
		config.texture,
		randf_range(config.size_range.x, config.size_range.y),
		config.points,
		config.damage,
		dir,
		config.speed
	)
	
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
	var angle_offsets = [randf_range(-PI / 6, PI / 6), randf_range(-PI / 6, PI / 6)]
	
	for offset in angle_offsets:
		var dir = direction.rotated(offset)
		var asteroid: Asteroid = asteroid_scene.instantiate()
		add_child(asteroid)
		
		asteroid.player_hit.connect(_on_player_hit)
		asteroid.position = position
		asteroid.setup(
			small_asteroid_config.texture,
			randf_range(small_asteroid_config.size_range.x, small_asteroid_config.size_range.y),
			small_asteroid_config.points,
			small_asteroid_config.damage,
			dir,
			small_asteroid_config.speed / 2
		)
