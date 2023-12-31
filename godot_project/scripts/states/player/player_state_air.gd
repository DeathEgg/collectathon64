class_name PlayerStateAir extends PlayerState


const _JUMP_SPEED = 10.0
const _BACKFLIP_SPEED = 13.0
const _VARIABLE_JUMP_HEIGHT_MAX_SPEED = 3.0
const _FAKE_VELOCITY_SPEED = 5.0

enum _JumpType { NONE, JUMP, BACKFLIP }
var _jump_type: _JumpType = _JumpType.NONE

var fake_velocity_center: Vector2 = Vector2.ZERO

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
		if not _has_jumped() and event.is_action_pressed("jump") and player.coyote_time > 0:
			_jump(_JumpType.JUMP)


func physics_update(delta) -> void:
	player.apply_gravity(delta)
	player.coyote_time -= delta
	
	# variable jump height (it's here rather than input due to jump buffering)
	if _has_jumped() and not Input.is_action_pressed("jump") and _jump_type != _JumpType.BACKFLIP:
		if player.velocity.y > _VARIABLE_JUMP_HEIGHT_MAX_SPEED:
			player.velocity.y = _VARIABLE_JUMP_HEIGHT_MAX_SPEED
	
	# movement
	var player_input = player.get_raw_player_movement_input()
	player_input = player_input.rotated(Vector3.UP, player.camera_manager.rotation.y)
	
	var movement_speed = Vector3.ZERO
	match _jump_type:
		_JumpType.NONE:
			movement_speed = player.movement_speed
		_JumpType.JUMP:
			movement_speed = player.movement_speed
		_JumpType.BACKFLIP:
			movement_speed = player.movement_speed / 4.0
	
	var movement_velocity = player_input * movement_speed * delta
	
	# subtract fake velocity so jumping off slopes feels good
	player.velocity -= Vector3(fake_velocity_center.x, 0, fake_velocity_center.y)
	var applied_velocity = player.velocity.lerp(movement_velocity, delta * player.ACCELERATION)
	
	player.velocity.x = applied_velocity.x
	player.velocity.z = applied_velocity.z
	# add fake velocity back
	player.velocity += Vector3(fake_velocity_center.x, 0, fake_velocity_center.y)
	
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
	
	if not player.is_on_walkable_angle():
		var floor_normal = player.get_floor_normal()
		
		fake_velocity_center = Vector2(floor_normal.x, floor_normal.z)
		fake_velocity_center *= _FAKE_VELOCITY_SPEED
	else:
		fake_velocity_center = Vector2.ZERO


func end(message: Dictionary = {}) -> void:
	player.coyote_time = player.COYOTE_TIME_MAX
	_jump_type = _JumpType.NONE
