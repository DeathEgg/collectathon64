class_name Player extends CharacterBody3D

@export var camera_manager: Node3D

var movement_speed: float
var movement_velocity: Vector3
var rotation_direction: float

const SPEED = 250.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 12.0 #ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_direction = ProjectSettings.get_setting("physics/3d/default_gravity_vector")


func _ready():
	movement_speed = SPEED


func apply_gravity(delta):
	velocity += gravity * gravity_direction * delta


func _physics_process(delta):
	pass
