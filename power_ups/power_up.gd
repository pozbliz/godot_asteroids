extends Area2D
class_name PowerUp


@export var texture: Texture2D
@export var default_speed: float = 50.0

var direction: Vector2 = Vector2.ZERO
var type

signal powerup_picked_up


func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)
	$DespawnTimer.start()

func _process(delta: float) -> void:
	var angle = randf_range(-PI, PI)
	direction = Vector2(cos(angle), sin(angle)).normalized()
	var velocity = direction * default_speed
	position += velocity * delta
	
func _on_body_entered(body):
	if body is Player:
		powerup_picked_up.emit(type)
		queue_free()

func _on_despawn_timer_timeout():
	queue_free()
