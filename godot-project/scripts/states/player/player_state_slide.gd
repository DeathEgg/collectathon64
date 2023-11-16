class_name PlayerStateSlide extends PlayerState


func input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("jump") and player.can_jump():
		state_machine.transition_to("Air", { "jump": true })


func physics_update(delta) -> void:
	# orient player to slide down the slope
	var down_slope_direction = player.get_floor_normal()
	down_slope_direction.y = -down_slope_direction.y
	
	var slide_speed = player.movement_speed * 1.5
	var movement_velocity: Vector3 = down_slope_direction * slide_speed * delta
	var applied_velocity = player.velocity.lerp(movement_velocity, delta * 10)
	
	player.velocity.x = applied_velocity.x
	player.velocity.y = -5
	player.velocity.z = applied_velocity.z
	
	player.move_and_slide()
	player.rotate_toward_forward_vector(delta)
	
	if not player.is_on_floor():
		state_machine.transition_to("Air")
	if player.is_on_walkable_angle():
		state_machine.transition_to("Walk")


func begin(message: Dictionary = {}) -> void:
	player.dust_particles.emitting = true
	player.disable_jump_for_time(0.2)


func end(message: Dictionary = {}) -> void:
	player.dust_particles.emitting = false
