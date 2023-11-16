class_name PlayerStateAir extends PlayerState


const _JUMP_VELOCITY = 8.0
const _VARIABLE_JUMP_HEIGHT_MAX_SPEED = 3.0
var _jumped = false

func _jump():
	if player.get_floor_angle(player.up_direction) > deg_to_rad(player.MAX_FLOOR_ANGLE):
		var floor_normal = player.get_floor_normal()
		player.velocity += _JUMP_VELOCITY * floor_normal
	else:
		player.velocity.y = _JUMP_VELOCITY
	_jumped = true


func input(event : InputEvent) -> void:
	# jump during coyote time
	if not _jumped and Input.is_action_just_pressed("jump") and player.coyote_time > 0:
		_jump()


func physics_update(delta) -> void:
	player.apply_gravity(delta)
	player.coyote_time -= delta
	
	# variable jump height (it's here rather than input due to jump buffering)
	if _jumped and not Input.is_action_pressed("jump"):
		if player.velocity.y > _VARIABLE_JUMP_HEIGHT_MAX_SPEED:
			player.velocity.y = _VARIABLE_JUMP_HEIGHT_MAX_SPEED
	
	# movement
	var input = Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backward")
	
	input = input.rotated(Vector3.UP, player.camera_manager.rotation.y).normalized()
	
	var movement_velocity = input * player.movement_speed * delta
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
			_jump()
		else:
			state_machine.transition_to("Walk")


func begin(message: Dictionary = {}) -> void:
	if message.has("jump") and message.jump == true:
		_jump()


func end(message: Dictionary = {}) -> void:
	player.coyote_time = player.COYOTE_TIME_MAX
	_jumped = false
