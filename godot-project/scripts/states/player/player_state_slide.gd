class_name PlayerStateSlide extends PlayerState


func input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", { "jump": true })


func physics_update(delta) -> void:
	player.apply_gravity(delta)
	
	# orient player to slide down the slope
	var down_slope_direction = player.get_floor_normal()
	down_slope_direction.y = 0
	
	var movement_velocity: Vector3 = down_slope_direction.normalized() * player.movement_speed * delta
	var applied_velocity = player.velocity.lerp(movement_velocity, delta * 10)
	
	player.velocity.x = applied_velocity.x
	player.velocity.z = applied_velocity.z
	
	player.move_and_slide()
	player.rotate_toward_forward_vector(delta)
	
	if player.is_on_walkable_angle():
		state_machine.transition_to("Walk")