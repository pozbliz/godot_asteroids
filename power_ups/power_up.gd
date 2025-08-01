extends Area2D
class_name PowerUp


@export var texture: Texture2D
@export var default_speed: float = 50.0

@onready var sprite = $Sprite2D
@onready var viewport = get_viewport_rect().size

var direction: Vector2 = Vector2.ZERO
var config: PowerUpConfig

signal powerup_picked_up(config: PowerUpConfig)


func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)
	$DespawnTimer.start()
	sprite.texture = texture
	scale = Vector2(1.5, 1.5)
	
	var angle = randf_range(-PI, PI)
	direction = Vector2(cos(angle), sin(angle)).normalized()

func _process(delta: float) -> void:
	var velocity = direction * default_speed
	position += velocity * delta
	
	if position.x < 0:
		position.x = viewport.x
	if position.x > viewport.x:
		position.x = 0
	if position.y < 0:
		position.y = viewport.y
	if position.y > viewport.y:
		position.y = 0
	
func _on_body_entered(body):
	if body is Player:
		powerup_picked_up.emit(config)
		queue_free()

func _on_despawn_timer_timeout():
	queue_free()
