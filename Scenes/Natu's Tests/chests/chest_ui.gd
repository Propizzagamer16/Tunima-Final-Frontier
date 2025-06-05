extends Control

@export var predefined_items: Array[GameItem] = []

func _ready():
	for i in range(min(predefined_items.size(), $GridContainer.get_child_count())):
		var slot = $GridContainer.get_child(i)
		slot.set_item(predefined_items[i])
