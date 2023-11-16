class_name PlayerStateIdle extends PlayerState


func input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", { "jump": true })
		return
		
	'''if Input.is_action_just_pressed("action"):
		state_machine.transition_to("Action")
		return
		
	if Input.is_action_just_pressed("crouch"):
		state_machine.transition_to("Crouch")
		return'''


func physics_update(delta) -> void:
	player.apply_gravity(delta)
	player.move_and_slide()
	player.rotate_toward_forward_vector(delta)
	
	# check if player is moving
	var input = Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backward")
	
	if input.x or input.z and player.is_on_floor():
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
