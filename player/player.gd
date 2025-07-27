extends CharacterBody2D
class_name Player


@onready var hp_bar = $HealthBar

@export var projectile_scene: PackedScene
@export var max_hp: int = 3

const ACCELERATION: float = 1.5
const MAX_SPEED: float = 800.0
const ROTATION_SPEED: float = 2.5
const FRICTION: float = 0.98
const SHOT_COOLDOWN : float = 0.3

var turn_direction: int = 0
var time_since_last_shot: float = 0.0
var current_hp: int
var is_invulnerable: bool = false

signal player_died


func _ready() -> void:
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
	
func _unhandled_input(event: InputEvent) -> void:
	turn_direction = Input.get_axis("turn_left", "turn_right")
	if Input.is_action_just_pressed("shoot") and time_since_last_shot >= SHOT_COOLDOWN:
		shoot()
	
func shoot():
	var shot = projectile_scene.instantiate()
	owner.add_child(shot)
	shot.transform = $CannonPosition.global_transform
	time_since_last_shot = 0
	
func take_damage(amount: int):
	if is_invulnerable:
		return
		
	is_invulnerable = true
	$InvulnerabilityTimer.start()
		
	current_hp -= amount
	hp_bar.visible = true
	hp_bar.value = current_hp
	
	if current_hp <= 0:
		$CollisionShape2D.set_deferred("disabled", true)
		player_died.emit()
	
func reset_player():
	current_hp = max_hp
	hp_bar.visible = false
	hp_bar.value = current_hp
	is_invulnerable = false
	$CollisionShape2D.set_deferred("disabled", false)
	
func _on_invulnerability_timer_timeout():
	is_invulnerable = false
	
func play_death_animation():
	pass
