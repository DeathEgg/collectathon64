class_name State extends Node


var state_machine : StateMachine = null


# Virtual function. Corresponds to Godot's "_unhandled_input()" function.
func input(event : InputEvent) -> void:
	pass


# Virtual function. Corresponds to Godot's "_process()" function.
func update(_delta) -> void:
	pass


# Virtual function. Corresponds to Godot's "_physics_process()" function.
func physics_update(_delta) -> void:
	pass


# Virtual function. Sets up the newly active state.
func begin(message: Dictionary = {}) -> void:
	pass


# Virtual function. Cleans up the current active state before switching to the next one.
func end() -> void:
	pass
