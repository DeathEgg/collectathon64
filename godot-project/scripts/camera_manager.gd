extends Node3D

@export_subgroup("Properties")
@export var target: Node

@export_subgroup("Zoom")
@export var minimum_zoom: float
@export var maximum_zoom: float

@export_subgroup("Rotation")
@export var rotation_speed = 120

var camera_rotation: Vector3

@onready var camera = $Camera

func _ready():
	camera_rotation = rotation_degrees
	camera_rotation.x = -10


func handle_input(delta):
	var input = Vector3.ZERO
	
	input.y = Input.get_axis("camera_right", "camera_left")
	input.x = Input.get_axis("camera_down", "camera_up")
	
	camera_rotation += input.limit_length(1.0) * rotation_speed * delta
	camera_rotation.x = clamp(camera_rotation.x, -80, 0)


func _physics_process(delta):
	self.position = self.position.lerp(target.position, delta * 4)
	rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 6)
	
	camera.position = camera.position.lerp(Vector3(0, 0, 10), 8 * delta)
	
	handle_input(delta)
