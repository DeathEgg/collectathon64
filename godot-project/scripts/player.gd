class_name Player extends CharacterBody3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var temp_meshes: Node3D = $Meshes
@onready var dust_particles: GPUParticles3D = $DustParticles

@export_subgroup("External Systems")
@export var camera_manager: Node3D
@export var player_inventory: PlayerInventory

const MAX_SPEED = 400.0
const ACCELERATION = 8.0
const DECELERATION = ACCELERATION

const COYOTE_TIME_MAX = 0.1
const JUMP_BUFFER_MAX = 0.1
const MAX_FLOOR_ANGLE = 40.0

var movement_speed: float
var movement_velocity: Vector3
var rotation_direction: float

# jump related variables
var coyote_time = COYOTE_TIME_MAX
var _jump_buffer = 0.0
var _disable_input_timer = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0 #ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_direction = ProjectSettings.get_setting("physics/3d/default_gravity_vector")


func disable_input_for_time(disable_length):
	_disable_input_timer = disable_length


func can_take_input() -> bool:
	return _disable_input_timer <= 0.0


func get_raw_player_movement_input():
	var player_input = Vector3.ZERO
	
	if can_take_input():
		player_input.x = Input.get_axis("move_left", "move_right")
		player_input.z = Input.get_axis("move_forward", "move_backward")
	
	return player_input


func apply_gravity(delta):
	velocity += gravity * gravity_direction * delta


func reset_jump_buffer():
	_jump_buffer = JUMP_BUFFER_MAX


func jump_buffer_active() -> bool:
	return _jump_buffer > 0.0


func is_on_walkable_angle():
	if is_on_floor():
		return get_floor_angle(up_direction) < deg_to_rad(MAX_FLOOR_ANGLE)
	
	return false


func floor_is_directly_below() -> bool:
	var space_state = get_world_3d().direct_space_state
	
	var start = Vector3.ZERO
	var end = Vector3(0, -1, 0)
	var query = PhysicsRayQueryParameters3D.create(start, end)
	var result = space_state.intersect_ray(query)
	
	# todo: check if result is a floor
	return not result.is_empty()


func rotate_toward_forward_vector(delta, rotation_speed = 10):
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * rotation_speed)


func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		reset_jump_buffer()


func _ready():
	movement_speed = MAX_SPEED


func _physics_process(delta):
	if _jump_buffer > 0:
		_jump_buffer -= delta
	if _disable_input_timer > 0:
		_disable_input_timer -= delta
