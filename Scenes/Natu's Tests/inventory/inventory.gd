extends Control

func _ready():
	$UI/InventoryUI.hide()
	$UI/weapon_upgrade.hide()

	var inventory_slots = $UI/InventoryUI.get_children()
	var hotbar_slots = $UI/Hotbar.get_children()

	# Load previously saved items
	InventoryManager.restore_to_slots(inventory_slots, InventoryManager.saved_inventory)
	InventoryManager.restore_to_slots(hotbar_slots, InventoryManager.saved_hotbar)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		var index = -1
		match event.keycode:
			KEY_1: index = 0
			KEY_2: index = 1
			KEY_3: index = 2
			KEY_4: index = 3
		if index >= 0:
			var hotbar = $UI/Hotbar
			if hotbar and index < hotbar.get_child_count():
				var slot = hotbar.get_child(index)
				if slot.item and slot.item.has_method("use"):
					var player = get_parent()
					if player:
						if slot.powerup_time > 0 or slot.cooldown_time > 0:
							return
						var used = slot.item.use(player)
						if used:
							var item_ref = slot.item
							slot.set_amount(slot.amount - 1)
							slot.powerup_duration = item_ref.duration
							slot.powerup_time = slot.powerup_duration
							slot.cooldown_duration = item_ref.cooldown
							slot.cooldown_time = 0.0

func save_inventory_state():
	var inventory_slots = $UI/InventoryUI.get_children()
	var hotbar_slots = $UI/Hotbar.get_children()
	InventoryManager.save_inventory(inventory_slots, hotbar_slots)
