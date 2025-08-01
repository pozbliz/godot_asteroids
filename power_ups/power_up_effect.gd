extends AnimatedSprite2D


@export var follow_target: Node2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	self.animation_finished.connect(_on_animation_finished)
	scale = Vector2(3.0, 3.0)
	
func _process(delta: float) -> void:
	if follow_target:
		global_position = follow_target.global_position
		
func _on_animation_finished():
	if animation == "heal":
		queue_free()
