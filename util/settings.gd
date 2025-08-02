extends Node


var powerups_enabled: bool = true


func _ready() -> void:
	load_settings()

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://options.cfg") == OK:
		powerups_enabled = config.get_value("gameplay", "powerups_enabled", true)

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("gameplay", "powerups_enabled", powerups_enabled)
	config.save("user://options.cfg")
