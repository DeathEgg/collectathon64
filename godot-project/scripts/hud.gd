extends RichTextLabel


@export var player_inventory: PlayerInventory

func _process(delta):
	var health: String = str(player_inventory.health)
	var magic: String = str(player_inventory.magic)
	text = "Health: " + health + "\nMagic: " + magic
