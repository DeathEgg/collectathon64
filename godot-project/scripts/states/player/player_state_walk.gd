class_name PlayerStateWalk extends PlayerState


const ACCELERATION = 8.0

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
	
	# movement
	var input = Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backward")
	
	input = input.rotated(Vector3.UP, player.camera_manager.rotation.y).normalized()
	
	var movement_velocity = input * player.movement_speed * delta
	var applied_velocity = player.velocity.lerp(movement_velocity, delta * ACCELERATION)
	
	player.velocity.x = applied_velocity.x
	player.velocity.z = applied_velocity.z
	
	player.move_and_slide()
	
	# rotate to face player direction
	if Vector2(player.velocity.z, player.velocity.x).length() > 0:
		player.rotation_direction = Vector2(player.velocity.z, player.velocity.x).angle()
		
	player.rotation.y = lerp_angle(player.rotation.y, player.rotation_direction, delta * 10)
	
	# check if the player no longer on the ground
	if not player.is_on_floor():
		state_machine.transition_to("Air")


func begin(message: Dictionary = {}) -> void:
	pass
