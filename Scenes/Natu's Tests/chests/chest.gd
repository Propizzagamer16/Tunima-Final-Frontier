extends Area2D

@onready var player : Node2D = null
var permanently_opened = false
@export var chest_contents: Array[Dictionary] = []


func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	$AnimatedSprite2D.play("closed")
	$ChestUI.hide()
	populate_chest()
	
func _process(delta: float) -> void:
	if self.overlaps_body(player) and Input.is_action_just_pressed("use"):
		print("blah")
		if not permanently_opened:
			$AnimatedSprite2D.play("opening")
			await $AnimatedSprite2D
			$AnimatedSprite2D.play("opened")
			permanently_opened = true
		$ChestUI.show()
		
func populate_chest():
	var slots = $ChestUI/GridContainer.get_children()
	for i in range(min(chest_contents.size(), slots.size())):
		var slot = slots[i]
		var item_data = chest_contents[i]
		if "item" in item_data and "amount" in item_data:
			slot.item = item_data["item"]
			slot.set_amount(item_data["amount"])
