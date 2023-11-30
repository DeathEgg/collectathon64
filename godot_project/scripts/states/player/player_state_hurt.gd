class_name PlayerStateHurt extends PlayerState


const _FLY_BACK_SPEED = 8.0

func physics_update(delta) -> void:
	player.apply_gravity(delta)
	player.move_and_slide()
	
	if player.is_on_floor():
		player.velocity *= -1
		state_machine.transition_to("Walk")


func begin(message: Dictionary = {}) -> void:
	# face player model toward the front before changing vlocity
	player.face_forward_vector()
	
	# get direction player is facing
	var forward_direction: Vector3 = player.get_global_transform().basis.z
	
	forward_direction.y = 0
	forward_direction = forward_direction.normalized()
	
	# flip it backward and add height
	var fly_direction = forward_direction * -1
	fly_direction.y = 2
	fly_direction = fly_direction.normalized()
	
	player.velocity = fly_direction * _FLY_BACK_SPEED


func end(message: Dictionary = {}) -> void:
	player.reset_invincibility_timer()
