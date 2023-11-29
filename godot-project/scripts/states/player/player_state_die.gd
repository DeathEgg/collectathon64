class_name PlayerStateDie extends PlayerState


func physics_update(delta) -> void:
	pass


func begin(message: Dictionary = {}) -> void:
	player.current_room.reset()


func end(message: Dictionary = {}) -> void:
	pass
