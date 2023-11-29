class_name Room extends Node


@export var player: Player

func reset():
	get_tree().reload_current_scene()


func _ready():
	# todo:
	# - decide music when entering room
	# - multiple entrances/exits, where they go, how they affect music
	
	pass


func _process(delta):
	pass
