extends Control

func populate(contents: Array[Dictionary]):
	var slots = $GridContainer.get_children()
	for i in range(min(contents.size(), slots.size())):
		var slot = slots[i]
		var item_data = contents[i]
		if "item" in item_data and "amount" in item_data:
			slot.item = item_data["item"]
			slot.set_amount(item_data["amount"])
