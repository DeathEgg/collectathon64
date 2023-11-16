class_name PlayerStateSlide extends PlayerState


const _SLIDE_ON_FLOOR_DECELERATION = 50.0
var _current_slide_speed = 0.0

func input(event : InputEvent) -> void:
	if player.can_take_input():
		if Input.is_action_just_pressed("jump"):
			state_machine.transition_to("Air", { "jump": true })


func physics_update(delta) -> void:
	# orient player to slide down the slope
	var down_slope_direction = player.get_floor_normal()
	down_slope_direction.y = -down_slope_direction.y
	
	var movement_velocity: Vector3 = down_slope_direction * _current_slide_speed * delta
	var applied_velocity = player.velocity.lerp(movement_velocity, delta * 10)
	var is_on_walkable_angle = player.is_on_walkable_angle()
	
	print(applied_velocity)
	player.velocity.x = applied_velocity.x
	if not is_on_walkable_angle:
		player.velocity.y = -player.gravity
	else:
		player.velocity.y = 0
	player.velocity.z = applied_velocity.z
	
	player.move_and_slide()
	player.rotate_toward_forward_vector(delta)
	
	if not player.is_on_floor():
		state_machine.transition_to("Air")
	if is_on_walkable_angle:
		if player.velocity.length_squared() > 5.0:
			_current_slide_speed -= _SLIDE_ON_FLOOR_DECELERATION * delta
		else:
			state_machine.transition_to("Walk")


func begin(message: Dictionary = {}) -> void:
	player.dust_particles.emitting = true
	player.disable_input_for_time(0.2)
	
	_current_slide_speed = player.movement_speed * 1.5


func end(message: Dictionary = {}) -> void:
	player.dust_particles.emitting = false
