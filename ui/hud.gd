extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/MessageTimer.timeout.connect(_on_message_timer_timeout)
	$MarginContainer/Message.hide()

func _process(delta: float) -> void:
	pass
	
func show_message(text):
	$MarginContainer/Message.text = text
	$MarginContainer/Message.show()
	$MarginContainer/MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	await $MarginContainer/MessageTimer.timeout
	
func update_score(score):
	$HBoxContainer/ScoreLabel.text = str(score)
	
func update_highscore(score):
	pass
	
func _on_message_timer_timeout():
	$MarginContainer/Message.hide()
