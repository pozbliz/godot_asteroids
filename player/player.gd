extends CharacterBody2D
class_name Player


@onready var hp_bar = $HealthBar

@export var projectile_scene: PackedScene
@export var max_hp: int = 3

const ACCELERATION: float = 1.5
const MAX_SPEED: float = 800.0
const ROTATION_SPEED: float = 3.0
const FRICTION: float = 0.98
const SHOT_COOLDOWN : float = 0.3
const EFFECT_SCENE = preload("res://power_ups/power_up_effect.tscn")

var turn_direction: int = 0
var time_since_last_shot: float = 0.0
var current_hp: int
var is_invulnerable: bool = false
var multishot_enabled: bool = false
var active_powerups := {}
var shield_effect_instance: Node = null

signal player_died


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	hide()
	current_hp = max_hp
	var hp_bar = $HealthBar
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	hp_bar.visible = false
	
	$InvulnerabilityTimer.timeout.connect(_on_invulnerability_timer_timeout)

func _physics_process(delta: float) -> void:
	var thrust = Vector2.ZERO
	
	rotation += turn_direction * ROTATION_SPEED * delta
	
	if Input.is_action_pressed("move_forward"):
		var target_velocity = transform.x * MAX_SPEED
		velocity = velocity.lerp(target_velocity, ACCELERATION * delta)
		$AnimatedSprite2D.play("moving")
	else:
		velocity *= FRICTION
		$AnimatedSprite2D.play("idle")
			
	move_and_slide()
	
func _process(delta: float) -> void:
	time_since_last_shot += delta
	_update_powerups(delta)
	
func _unhandled_input(event: InputEvent) -> void:
	turn_direction = Input.get_axis("turn_left", "turn_right")
	if Input.is_action_just_pressed("shoot") and time_since_last_shot >= SHOT_COOLDOWN:
		shoot()
	
func shoot():
	var shot = projectile_scene.instantiate()
	owner.add_child(shot)
	shot.transform = $CannonPosition.global_transform
	
	if multishot_enabled:
		var multishot_angles: Array = [-10, 10]
		for angle in multishot_angles:
			shot = projectile_scene.instantiate()
			shot.global_position = $CannonPosition.global_position
			shot.rotation = $CannonPosition.global_rotation + deg_to_rad(angle)
	
			owner.add_child(shot)
	
	AudioManager.play("res://art/sound/Bluezone_BC0295_sci_fi_weapon_gun_shot_008.wav", randf_range(0.8, 1.2))
	time_since_last_shot = 0
	
func take_damage(amount: int):
	if is_invulnerable:
		return
		
	is_invulnerable = true
	$InvulnerabilityTimer.start()
		
	current_hp -= amount
	toggle_hpbar()
	hp_bar.value = current_hp
	
	if current_hp <= 0:
		$CollisionShape2D.set_deferred("disabled", true)
		player_died.emit()
		
func toggle_hpbar():
	if current_hp < max_hp:
		hp_bar.show()
	else:
		hp_bar.hide()
	
func reset_player():
	show()
	current_hp = max_hp
	toggle_hpbar()
	hp_bar.value = current_hp
	is_invulnerable = false
	time_since_last_shot = SHOT_COOLDOWN
	$CollisionShape2D.set_deferred("disabled", false)
	
func _on_invulnerability_timer_timeout():
	is_invulnerable = false
	
func heal(amount: int):
	current_hp += amount
	if current_hp > max_hp:
		current_hp = max_hp
	toggle_hpbar()
	hp_bar.value = current_hp
	
func activate_powerup(powerup_name: String, duration: float) -> void:
	if active_powerups.has(powerup_name):
		active_powerups[powerup_name] += duration
	else:
		active_powerups[powerup_name] = duration
		_start_powerup(powerup_name)
	
func _update_powerups(delta: float) -> void:
	for powerup in active_powerups.keys():
		active_powerups[powerup] -= delta
		if active_powerups[powerup] <= 0:
			_end_powerup(powerup)
	
func _start_powerup(powerup_name: String) -> void:
	match powerup_name:
		"multishot":
			multishot_enabled = true
		"shield":
			shield_effect_instance = EFFECT_SCENE.instantiate()
			shield_effect_instance.global_position = global_position
			get_tree().current_scene.add_child(shield_effect_instance)
			shield_effect_instance.follow_target = self
			shield_effect_instance.set_as_top_level(true)
			shield_effect_instance.play("shield")
			is_invulnerable = true
		"heal":
			var effect = EFFECT_SCENE.instantiate()
			effect.global_position = global_position
			get_tree().current_scene.add_child(effect)
			effect.follow_target = self
			effect.set_as_top_level(true)
			effect.play("heal")
			heal(3)

func _end_powerup(powerup_name: String) -> void:
	match powerup_name:
		"multishot":
			multishot_enabled = false
		"shield":
			is_invulnerable = false
			if shield_effect_instance:
				shield_effect_instance.queue_free()
				shield_effect_instance = null
		_:
			pass
	active_powerups.erase(powerup_name)
	
func play_death_animation():
	$HealthBar.hide()
	$AnimatedSprite2D.play("death")
	AudioManager.play("res://art/sound/Bluezone_BC0294_modern_cinematic_impact_boom_003.wav", 1.0, 10.0)
