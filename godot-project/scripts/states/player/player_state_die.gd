class_name PlayerStateDie extends PlayerState


func physics_update(delta) -> void:
	pass


func begin(message: Dictionary = {}) -> void:
	get_tree().reload_current_scene()


func end(message: Dictionary = {}) -> void:
	pass
