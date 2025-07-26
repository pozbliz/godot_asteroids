extends Area2D


signal player_hit
signal asteroid_hit


func _ready() -> void:
	body_entered.connect(_on_asteroid_body_entered)

func _process(delta: float) -> void:
	pass

func _on_asteroid_body_entered(body):
	if body is Player:
		player_hit.emit()

func _on_asteroid_area_entered(area):
	if area is Projectile:
		asteroid_hit.emit()
