class_name PlayerStateWalk extends PlayerState


const _SLOW_DOWN_ON_SLOPE_SCALAR = 300.0
const _MIN_SLOPE_GRIP_SPEED = 20.0
var _current_max_walk_speed = 0.0

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
	# movement
	var player_input = Vector3.ZERO
	
	if player.can_take_input():
		player_input.x = Input.get_axis("move_left", "move_right")
		player_input.z = Input.get_axis("move_forward", "move_backward")
	
	player_input = player_input.rotated(Vector3.UP, player.camera_manager.rotation.y)
	
	var movement_velocity = player_input * _current_max_walk_speed * delta
	var applied_velocity = player.velocity.lerp(movement_velocity, delta * player.ACCELERATION)
	
	player.velocity.x = applied_velocity.x
	player.velocity.z = applied_velocity.z
	
	player.apply_gravity(delta)
	player.move_and_slide()
	
	# check if the player no longer on the ground
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		player.rotate_toward_forward_vector(delta)
	# check if the player is on a steep slope
	elif not player.is_on_walkable_angle():
		var floor_normal = player.get_floor_normal()
		
		if _current_max_walk_speed > _MIN_SLOPE_GRIP_SPEED and floor_normal.dot(player.velocity) < 0.0:
			_current_max_walk_speed -= _SLOW_DOWN_ON_SLOPE_SCALAR * delta
			player.rotate_toward_forward_vector(delta, 2)
		else:
			state_machine.transition_to("Slide")
	else:
		_current_max_walk_speed = player.movement_speed
		player.rotate_toward_forward_vector(delta)


func begin(message: Dictionary = {}) -> void:
	_current_max_walk_speed = player.movement_speed
