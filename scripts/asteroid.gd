extends Node2D
class_name Asteroid


@export var default_speed: float = 200.0
@export var size: float = 1.0
@export var points: int = 1

var direction: Vector2 = Vector2.ZERO


signal player_hit
signal asteroid_hit


func _ready() -> void:
	$Area2D.body_entered.connect(_on_asteroid_body_entered)
	$Area2D.area_entered.connect(_on_asteroid_area_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _process(delta: float) -> void:
	var velocity = direction * default_speed * randf_range(0.75, 1.25)
	position += velocity * delta
	
func rescale(size_value: float):
	size = size_value
	scale = Vector2(size, size)

func _on_asteroid_body_entered(body):
	if body is Player:
		player_hit.emit()

func _on_asteroid_area_entered(area):
	if area is Projectile:
		asteroid_hit.emit(points)
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		queue_free()
		
func _on_screen_exited():
	queue_free()
