extends Area2D


const PROJECTILE_SPEED: float = 600.0

var direction: Vector2 = Vector2.ZERO


signal projectile_hit


func _ready() -> void:
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _process(delta: float) -> void:
	var velocity = direction * PROJECTILE_SPEED
	position += velocity * delta
	
func _on_area_entered():
	queue_free()
	projectile_hit.emit()
	
func _on_screen_exited():
	queue_free()
