class_name PlayerStateHurt extends PlayerState


func begin(message: Dictionary = {}) -> void:
	player.is_invincible = true


func end(message: Dictionary = {}) -> void:
	pass
