extends Node

var saved_inventory : Array[Dictionary] = []
var saved_hotbar : Array[Dictionary] = []

func save_inventory(slots: Array[Node]):
	saved_inventory = []
	for slot in slots:
		saved_inventory.append({
			"item": slot.item,
			"amount": slot.amount
		})

func save_hotbar(slots: Array[Node]):
	saved_hotbar = []
	for slot in slots:
		saved_hotbar.append({
			"item": slot.item,
			"amount": slot.amount
		})

func restore_to_slots(slots: Array[Node], data: Array[Dictionary]):
	for i in data.size():
		if i < slots.size():
			var slot = slots[i]
			slot.item = data[i]["item"]
			slot.amount = data[i]["amount"]
