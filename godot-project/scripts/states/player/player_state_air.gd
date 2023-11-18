class_name PlayerStateAir extends PlayerState


enum _JumpType { NONE, JUMP, BACKFLIP }
var _jump_type: _JumpType = _JumpType.NONE

const _JUMP_SPEED = 8.0
const _BACKFLIP_SPEED = 10.0
const _VARIABLE_JUMP_HEIGHT_MAX_SPEED = 3.0

func _jump(type: _JumpType):
	var jump_speed: float = 0.0
	
	# determine initial jump speed based on type of jump
	assert(type != _JumpType.NONE)
	match type:
		_JumpType.JUMP:
			jump_speed = _JUMP_SPEED
		_JumpType.BACKFLIP:
			jump_speed = _BACKFLIP_SPEED
	
	# jump at an angle if jumping from a steep slope
	if player.get_floor_angle(player.up_direction) > deg_to_rad(player.MAX_FLOOR_ANGLE):
		var floor_normal = player.get_floor_normal()
		player.velocity += jump_speed * floor_normal
	else:
		player.velocity.y = jump_speed
	
	_jump_type = type


func _has_jumped() -> bool:
	return _jump_type != _JumpType.NONE


func input(event : InputEvent) -> void:
	if player.can_take_input():
		# jump during coyote time
		if not _has_jumped() and Input.is_action_just_pressed("jump") and player.coyote_time > 0:
			_jump(_JumpType.JUMP)


func physics_update(delta) -> void:
	player.apply_gravity(delta)
	player.coyote_time -= delta
	
	# variable jump height (it's here rather than input due to jump buffering)
	if _has_jumped() and not Input.is_action_pressed("jump"):
		if player.velocity.y > _VARIABLE_JUMP_HEIGHT_MAX_SPEED:
			player.velocity.y = _VARIABLE_JUMP_HEIGHT_MAX_SPEED
	
	# movement
	var player_input = Vector3.ZERO
	
	if player.can_take_input():
		player_input.x = Input.get_axis("move_left", "move_right")
		player_input.z = Input.get_axis("move_forward", "move_backward")
	
	player_input = player_input.rotated(Vector3.UP, player.camera_manager.rotation.y)
	
	var movement_velocity = player_input * player.movement_speed * delta
	var applied_velocity = player.velocity.lerp(movement_velocity, delta * 10)
	
	player.velocity.x = applied_velocity.x
	player.velocity.z = applied_velocity.z
	
	player.move_and_slide()
	player.rotate_toward_forward_vector(delta)
	
	# check if the player has landed
	if player.is_on_floor():
		if not player.is_on_walkable_angle():
			state_machine.transition_to("Slide")
		elif player.jump_buffer_active():
			_jump(_JumpType.JUMP)
		else:
			state_machine.transition_to("Walk")


func begin(message: Dictionary = {}) -> void:
	if message.has("jump") and message.jump == true:
		_jump(_JumpType.JUMP)
	if message.has("backflip") and message.backflip == true:
		_jump(_JumpType.BACKFLIP)


func end(message: Dictionary = {}) -> void:
	player.coyote_time = player.COYOTE_TIME_MAX
	_jump_type = _JumpType.NONE
