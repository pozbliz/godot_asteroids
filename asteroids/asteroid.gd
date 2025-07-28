extends Node2D
class_name Asteroid


@export var default_speed: float = 200.0
@export var size: float = 1.0
@export var points: int = 1
@export var damage: int = 1
@export var texture: Texture2D

var direction: Vector2 = Vector2.ZERO
var is_hit: bool = false
var velocity: Vector2 = Vector2.ZERO
var spawn_immunity_time: float = 0.1
var time_since_spawn: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D

signal player_hit
signal asteroid_hit


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	sprite.texture = texture
	rescale(size)
	
	$Area2D.body_entered.connect(_on_asteroid_body_entered)
	$Area2D.area_entered.connect(_on_asteroid_area_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)
	
	add_to_group("asteroids")
	
func setup(
		texture: Texture2D, 
		size: float, 
		points_value: int, 
		damage_value: int, 
		dir: Vector2, 
		speed: float = default_speed
	) -> void:
		
	# Initialize visuals
	sprite.texture = texture
	rescale(size)

	# Assign gameplay values
	points = points_value
	damage = damage_value

	# Movement
	direction = dir.normalized()
	velocity = direction * speed * randf_range(0.75, 1.25)
	rotation = direction.angle()

func _process(delta: float) -> void:
	position += velocity * delta
	time_since_spawn += delta
	
func rescale(size_value: float):
	scale = Vector2(size_value, size_value)
	
func _on_asteroid_body_entered(body):
	if body is Player:
		player_hit.emit(damage)

func _on_asteroid_area_entered(area):
	if is_hit or time_since_spawn < spawn_immunity_time:
		return
		
	if area is Projectile:
		is_hit = true
		asteroid_hit.emit(points, position, direction)
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		queue_free()
		
func _on_screen_exited():
	queue_free()
