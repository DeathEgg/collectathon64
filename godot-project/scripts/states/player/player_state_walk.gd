class_name PlayerStateWalk extends PlayerState


func input(event : InputEvent) -> void:
	if player.can_take_input():
		if Input.is_action_just_pressed("jump"):
			state_machine.transition_to("Air", { "jump": true })
			return
		
		'''if Input.is_action_just_pressed("action"):
			state_machine.transition_to("Action")
			return'''
		
		if Input.is_action_just_pressed("crouch"):
			state_machine.transition_to("Crouch")
			return


func physics_update(delta) -> void:
	# movement
	var player_input = Vector3.ZERO
	
	if player.can_take_input():
		player_input.x = Input.get_axis("move_left", "move_right")
		player_input.z = Input.get_axis("move_forward", "move_backward")
	
	player_input = player_input.rotated(Vector3.UP, player.camera_manager.rotation.y)
	
	var movement_velocity = player_input * player.movement_speed * delta
	var applied_velocity = player.velocity.lerp(movement_velocity, delta * player.ACCELERATION)
	
	player.velocity.x = applied_velocity.x
	player.velocity.z = applied_velocity.z
	
	player.apply_gravity(delta)
	player.move_and_slide()
	player.rotate_toward_forward_vector(delta)
	
	# check if the player no longer on the ground
	if not player.is_on_floor():
		state_machine.transition_to("Air")
	# check if the player is on a steep slope
	elif not player.is_on_walkable_angle():
		# todo: make player try to run up the slope a bit first and slow them down
		state_machine.transition_to("Slide")


func begin(message: Dictionary = {}) -> void:
	pass
