extends Node


@export var asteroid_scene: PackedScene
@export var asteroid_small_scene: PackedScene

@onready var invulnerability_timer: Timer = Timer.new()
@onready var hp_bar = $Player/HealthBar

var score: int = 0
var current_hp: int
var is_invulnerable: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$UI.game_started.connect(_on_ui_game_started)
	$UI.open_main_menu()
	$Audio/AudioMainMenu.play()
	
	$AsteroidTimer.timeout.connect(_on_asteroid_timer_timeout)
	$InvulnerabilityTimer.timeout.connect(_on_invulnerability_timer_timeout)

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
	current_hp = $Player.max_hp
	hp_bar.visible = false
	hp_bar.value = current_hp
	is_invulnerable = false
	$AsteroidTimer.start()
	
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
	var angle = asteroid_spawn_location.rotation + PI/2
	# Add some randomness to the direction.
	angle += randf_range(-PI / 4, PI / 4)
	asteroid.rotation = angle
	asteroid.direction = Vector2(cos(angle), sin(angle)).normalized()
	
func create_asteroid() -> Asteroid:
	var asteroid = asteroid_scene.instantiate()
	add_child(asteroid)
	asteroid.player_hit.connect(_on_player_hit)
	asteroid.asteroid_hit.connect(_on_asteroid_hit)
	asteroid.rescale(randf_range(3.0, 6.0))
	asteroid.points = 2
	
	return asteroid
	
func create_small_asteroid() -> Asteroid:
	var asteroid = asteroid_small_scene.instantiate()
	add_child(asteroid)
	asteroid.player_hit.connect(_on_player_hit)
	asteroid.asteroid_hit.connect(_on_asteroid_hit)
	asteroid.rescale(randf_range(1.5, 2.5))
	asteroid.points = 1
	
	return asteroid
	
func _on_player_hit():
	if is_invulnerable:
		return
		
	is_invulnerable = true
	$InvulnerabilityTimer.start()
		
	current_hp -= 1
	hp_bar.visible = true
	hp_bar.value = current_hp
	
	if current_hp <= 0:
		$Player/CollisionShape2D.set_deferred("disabled", true)
		game_over()
	
func game_over():
	await $UI/HUD.show_game_over()
	$UI.open_main_menu()
	play_main_menu_music()
	
func _on_asteroid_hit(points):
	# split asteroid into smaller pieces
	score += points
	$UI/HUD.update_score(score)
	
func _on_invulnerability_timer_timeout():
	is_invulnerable = false
