class_name PlayerStateCrouch extends PlayerState


const _CROUCH_DECELERATION = 2.0
const _MAX_BACKFLIP_SPEED_SQUARED = 3.0 * 3.0

func input(event : InputEvent) -> void:
	if player.can_take_input():# and player.velocity.length_squared() < _MAX_BACKFLIP_SPEED_SQUARED:
		if event.is_action_pressed("jump"):
			state_machine.transition_to("Air", { "backflip": true })
			

func physics_update(delta) -> void:
	player.apply_gravity(delta)
	
	player.velocity = player.velocity.lerp(Vector3.ZERO, _CROUCH_DECELERATION * delta)
	
	player.move_and_slide()
	player.rotate_toward_forward_vector(delta)
	
	if player.velocity.length_squared() > 1.0:
		player.dust_particles.emitting = true
	else:
		player.dust_particles.emitting = false
	
	# check if the player had the rug pulled out from under them
	if not player.is_on_floor():
		state_machine.transition_to("Air")
	# check if the player is on a steep slope
	elif not player.is_on_walkable_angle():
		state_machine.transition_to("Slide")
	# what if the player no longer wants to crouch?
	elif not Input.is_action_pressed("crouch"):
		if player.velocity.length_squared() > 0.1:
			state_machine.transition_to("Walk")
		else:
			state_machine.transition_to("Idle")


func begin(message: Dictionary = {}) -> void:
	player.temp_meshes.scale = Vector3(1.0, 0.5, 1.0)
	player.temp_meshes.position -= Vector3(0.0, 0.5, 0.0)


func end(message: Dictionary = {}) -> void:
	player.temp_meshes.scale = Vector3.ONE
	player.temp_meshes.position += Vector3(0.0, 0.5, 0.0)
	
	player.dust_particles.emitting = false
