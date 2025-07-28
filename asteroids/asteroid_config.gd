# asteroid_config.gd
extends Resource
class_name AsteroidConfig

@export var texture: Texture2D
@export var size_range: Vector2 = Vector2(1.0, 2.0)
@export var points: int = 1
@export var damage: int = 1
@export var speed: float = 200.0
