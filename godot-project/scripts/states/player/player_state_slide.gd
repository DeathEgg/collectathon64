class_name PlayerStateSlide extends PlayerState


const _SLIDE_CONTROL_LOCK_TIME = 0.2
const _MIN_STARTING_SLIDE_SPEED = 150.0
const _SLIDE_ON_FLOOR_DECELERATION = 50.0
const _MAX_SLIDE_SPEED = 600.0
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
	# orient player to slide down the slope
	var down_slope_direction = _get_down_slope_direction()
	
	var movement_velocity: Vector3 = down_slope_direction * _current_slide_speed * delta
	var applied_velocity: Vector3 = player.velocity.lerp(movement_velocity, delta * player.ACCELERATION)
	
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


func end(message: Dictionary = {}) -> void:
	player.dust_particles.emitting = false
