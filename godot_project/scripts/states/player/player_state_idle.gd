class_name PlayerStateIdle extends PlayerState


func input(event : InputEvent) -> void:
	if player.can_take_input():
		if event.is_action_pressed("jump"):
			state_machine.transition_to("Air", { "jump": true })
			return
		
		'''if event.is_action_pressed("action"):
			state_machine.transition_to("Action")
			return'''
		
		if event.is_action_pressed("crouch"):
			state_machine.transition_to("Crouch")
			return


func physics_update(delta) -> void:
	player.apply_gravity(delta)
	player.move_and_slide()
	player.rotate_toward_forward_vector(delta)
	
	# check if player is moving
	var player_input = player.get_raw_player_movement_input()
	
	if player_input.x or player_input.z and player.is_on_floor():
		state_machine.transition_to("Walk")
	
	# check if the player had the rug pulled out from under them
	if not player.is_on_floor():
		state_machine.transition_to("Air")
	# check if the player is on a steep slope
	elif not player.is_on_walkable_angle():
		state_machine.transition_to("Slide")


func begin(message: Dictionary = {}) -> void:
	player.velocity.x = 0
	player.velocity.z = 0
