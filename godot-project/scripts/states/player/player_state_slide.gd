class_name PlayerStateSlide extends PlayerState


const _SLIDE_CONTROL_LOCK_TIME = 0.2
const _MIN_STARTING_SLIDE_SPEED = 150.0
const _SLIDE_ON_FLOOR_DECELERATION = 50.0
const _MAX_SLIDE_SPEED = 600.0
const _ACOS_MAX_ANGLE = 0.3
const _MAX_ANGLE = cos(_ACOS_MAX_ANGLE)
var _current_slide_speed = 0.0

func _get_down_slope_direction():
	var down_slope_direction: Vector3 = player.get_floor_normal()
	down_slope_direction.y = -down_slope_direction.y
	
	return down_slope_direction


func input(event : InputEvent) -> void:
	if player.can_take_input():
		if event.is_action_pressed("jump"):
			state_machine.transition_to("Air", { "jump": true })


func physics_update(delta) -> void:
	# get player input for if they're trying to direct which direction to slide in
	var player_input: Vector3 = player.get_raw_player_movement_input()
	player_input = player_input.rotated(Vector3.UP, player.camera_manager.rotation.y)
	
	var down_slope_direction: Vector3 = _get_down_slope_direction()
	var slide_direction: Vector3
	
	if player_input != Vector3.ZERO:
		var axis: Vector3 = down_slope_direction
		axis.y = 0
		axis = axis.normalized()
		
		# if within degree of facing forward
		if player_input.dot(down_slope_direction) >= _ACOS_MAX_ANGLE:
			slide_direction = player_input
		elif player_input.dot(down_slope_direction) >= -_ACOS_MAX_ANGLE:
			var forward_vector = down_slope_direction
			forward_vector.y = 0
			var cross_product = forward_vector.cross(player_input)
			
			if cross_product.y > 0:
				slide_direction = down_slope_direction.rotated(axis, _MAX_ANGLE)
			else:
				slide_direction = down_slope_direction.rotated(axis, -_MAX_ANGLE)
		else:
			slide_direction = player.velocity.normalized()
	else:
		slide_direction = player.velocity.normalized()
	
	var movement_velocity: Vector3 = slide_direction * _current_slide_speed * delta
	var applied_velocity: Vector3 = player.velocity.lerp(movement_velocity, player.ACCELERATION * delta)
	
	player.velocity.x = applied_velocity.x
	player.velocity.y = movement_velocity.y
	player.velocity.z = applied_velocity.z
	
	player.move_and_slide()
	player.rotate_toward_forward_vector(delta)
	
	# fall off ledges
	if not player.is_on_floor():
		state_machine.transition_to("Air")
	# slow down if on walkable floor again
	elif player.is_on_walkable_angle():
		if player.velocity.length_squared() > 5.0:
			_current_slide_speed -= _SLIDE_ON_FLOOR_DECELERATION * delta
		else:
			state_machine.transition_to("Walk")
	# speed up if still on steep angled slope
	else:
		_current_slide_speed += _MAX_SLIDE_SPEED * delta
		if _current_slide_speed > _MAX_SLIDE_SPEED:
			_current_slide_speed = _MAX_SLIDE_SPEED


func begin(message: Dictionary = {}) -> void:
	player.dust_particles.emitting = true
	player.disable_input_for_time(_SLIDE_CONTROL_LOCK_TIME)
	
	_current_slide_speed = player.velocity.length()
	if _current_slide_speed < _MIN_STARTING_SLIDE_SPEED:
		_current_slide_speed = _MIN_STARTING_SLIDE_SPEED
	
	# set initial direction for player to be sliding
	player.velocity = _get_down_slope_direction()


func end(message: Dictionary = {}) -> void:
	player.dust_particles.emitting = false
