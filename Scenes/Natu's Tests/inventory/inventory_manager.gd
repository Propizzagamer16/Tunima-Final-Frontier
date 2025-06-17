extends Node

var saved_inventory: Array = []
var saved_hotbar: Array = []

func save_inventory(inventory_slots: Array, hotbar_slots: Array):
	saved_inventory.clear()
	saved_hotbar.clear()

	for slot in inventory_slots:
		if slot.item:
			saved_inventory.append({
				"item_path": slot.item.resource_path,
				"amount": slot.amount
			})
		else:
			saved_inventory.append(null)

	for slot in hotbar_slots:
		if slot.item:
			saved_hotbar.append({
				"item_path": slot.item.resource_path,
				"amount": slot.amount
			})
		else:
			saved_hotbar.append(null)

func restore_to_slots(target_slots: Array, saved_data: Array):
	for i in target_slots.size():
		if i < saved_data.size() and saved_data[i] != null:
			var item = load(saved_data[i]["item_path"])
			target_slots[i].item = item
			target_slots[i].amount = saved_data[i]["amount"]
		else:
			target_slots[i].item = null
			target_slots[i].amount = 0
