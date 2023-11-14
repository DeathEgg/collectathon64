class_name PlayerStateAir extends PlayerState


const JUMP_VELOCITY = 8.0
var jumped = false

func input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("jump") and player.coyote_time:
		player.velocity.y = JUMP_VELOCITY
		jumped = true


func physics_update(delta) -> void:
	player.apply_gravity(delta)
	
	player.coyote_time -= delta
	
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
	
	# rotate to face player direction
	if Vector2(player.velocity.z, player.velocity.x).length() > 0:
		player.rotation_direction = Vector2(player.velocity.z, player.velocity.x).angle()
		
	player.rotation.y = lerp_angle(player.rotation.y, player.rotation_direction, delta * 10)
	
	# check if the player has landed
	if player.is_on_floor():
		state_machine.transition_to("Walk")


func begin(message: Dictionary = {}) -> void:
	if message.has("jump") and message.jump == true:
		player.velocity.y = JUMP_VELOCITY
		jumped = true
	else:
		jumped = false


func end(message: Dictionary = {}) -> void:
	player.coyote_time = player.COYOTE_TIME_MAX
