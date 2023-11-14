class_name PlayerState extends State


## Initial animation name. Can be changed.
@export var _animation_name: String = "idle"

var player : Player
var _current_animation_name: String

# Called when the node enters the scene tree for the first time.
func _ready():
	await owner._ready
	player = owner as Player
	assert(player != null)
	
	_current_animation_name = _animation_name


func get_animation_name() -> String:
	return _current_animation_name


func set_animation(new_name: String):
	_current_animation_name = new_name


func restore_original_animation():
	_current_animation_name = _animation_name
