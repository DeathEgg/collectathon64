class_name Player extends CharacterBody3D

@export var camera_manager: Node3D

const MAX_SPEED = 320.0
const COYOTE_TIME_MAX = 0.1
const JUMP_BUFFER_MAX = 0.1

var movement_speed: float
var movement_velocity: Vector3
var rotation_direction: float

# jump related variables
var coyote_time = COYOTE_TIME_MAX
var jump_buffer = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 15.0 #ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_direction = ProjectSettings.get_setting("physics/3d/default_gravity_vector")


func apply_gravity(delta):
	velocity += gravity * gravity_direction * delta


func reset_jump_buffer():
	jump_buffer = JUMP_BUFFER_MAX


func jump_buffer_active():
	return jump_buffer > 0.0


func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		reset_jump_buffer()


func _ready():
	movement_speed = MAX_SPEED


func _physics_process(delta):
	jump_buffer -= delta
