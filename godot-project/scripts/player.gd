class_name Player extends CharacterBody3D

@onready var dust_particles: GPUParticles3D = $DustParticles

@export var camera_manager: Node3D

const MAX_SPEED = 400.0
const COYOTE_TIME_MAX = 0.1
const JUMP_BUFFER_MAX = 0.1
const MAX_FLOOR_ANGLE = 20.0

var movement_speed: float
var movement_velocity: Vector3
var rotation_direction: float

# jump related variables
var coyote_time = COYOTE_TIME_MAX
var _jump_buffer = 0.0
var _disable_jump_timer = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 15.0 #ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_direction = ProjectSettings.get_setting("physics/3d/default_gravity_vector")


func apply_gravity(delta):
	velocity += gravity * gravity_direction * delta


func reset_jump_buffer():
	_jump_buffer = JUMP_BUFFER_MAX


func jump_buffer_active() -> bool:
	return _jump_buffer > 0.0


func disable_jump_for_time(disable_length):
	_disable_jump_timer = disable_length


func can_jump() -> bool:
	return _disable_jump_timer <= 0.0


func is_on_walkable_angle():
	if is_on_floor():
		if get_floor_angle(up_direction) < deg_to_rad(MAX_FLOOR_ANGLE):
			return true
	
	return false


func rotate_toward_forward_vector(delta):
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)


func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		reset_jump_buffer()


func _ready():
	movement_speed = MAX_SPEED


func _physics_process(delta):
	if _jump_buffer > 0:
		_jump_buffer -= delta
	if _disable_jump_timer > 0:
		_disable_jump_timer -= delta
