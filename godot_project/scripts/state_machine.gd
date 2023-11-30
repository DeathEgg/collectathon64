class_name StateMachine extends Node


# Emitted when transitioning to a new state.
signal transitioned(new_state)

# Initial state we run the state machine with.
@export var initial_state : NodePath = NodePath()

# The current active state.
@onready var _state : State = get_node(initial_state)


# Called when the node enters the scene tree for the first time.
func _ready():
	if owner.has_method("_ready"):
		await owner._ready
	
	# Initialize child states reference to parent state machine.
	for child in get_children():
		child.state_machine = self
	
	_state.begin()


func _unhandled_input(event):
	_state.input(event)


func _process(delta):
	if _state.has_method("get_animation_name") and owner.has_method("get_animation_player"):
		var animation_player = owner.get_animation_player()
		if animation_player != null:
			animation_player.play(_state.get_animation_name())
	_state.update(delta)


func _physics_process(delta):
	_state.physics_update(delta)


func transition_to(new_state_name : String, message: Dictionary = {}):
	if not has_node(new_state_name):
		assert("Requested state does not exist!")
	
	_state.end()
	_state = get_node(new_state_name)
	_state.begin(message)
	emit_signal("transitioned", _state.name)


func get_current_state_name() -> String:
	return _state.name


func get_current_state() -> State:
	return _state
