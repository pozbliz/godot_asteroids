extends Area2D
class_name Projectile


const PROJECTILE_SPEED: float = 600.0


signal projectile_hit


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _process(delta: float) -> void:
	var velocity = transform.x.normalized() * PROJECTILE_SPEED
	position += velocity * delta
	
func _on_area_entered():
	queue_free()
	projectile_hit.emit()
	
func _on_screen_exited():
	queue_free()
