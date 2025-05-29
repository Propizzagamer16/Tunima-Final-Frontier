extends Control

func _ready():
	$UI/InventoryUI.hide()
	
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		var index = -1
		match event.keycode:
			KEY_1: index = 0
			KEY_2: index = 1
			KEY_3: index = 2
		if index >= 0:
			var hotbar = $UI/Hotbar
			if hotbar and index < hotbar.get_child_count():
				var slot = hotbar.get_child(index)
				if slot.item and slot.item.has_method("use"):
					var player = get_tree().get_first_node_in_group("Player")
					if player:
						slot.item.use(player)
						slot.set_amount(slot.amount - 1)
