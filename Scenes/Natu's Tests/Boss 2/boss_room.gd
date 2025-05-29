extends Node2D

func _ready():
	var hotbar_ui = get_node("Inventory/UI/Hotbar")
	hotbar_ui.visible = true
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("inventory"):
		var inventory_ui = get_node("Inventory/UI/InventoryUI")
		inventory_ui.visible = not inventory_ui.visible
