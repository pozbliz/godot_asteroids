extends CharacterBody2D


const ACCELERATION: float = 1.5
const MAX_SPEED: float = 800.0
const ROTATION_SPEED: float = 2.5
const FRICTION = 0.98

var turn_direction: int = 0


func _physics_process(delta: float) -> void:
	var thrust = Vector2.ZERO
	
	rotation += turn_direction * ROTATION_SPEED * delta
	
	if Input.is_action_pressed("move_forward"):
		var target_velocity = transform.x * MAX_SPEED
		velocity = velocity.lerp(target_velocity, ACCELERATION * delta)
	else:
		velocity *= FRICTION
			
	move_and_slide()
	
func _process(delta: float) -> void:
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	turn_direction = Input.get_axis("turn_left", "turn_right")
