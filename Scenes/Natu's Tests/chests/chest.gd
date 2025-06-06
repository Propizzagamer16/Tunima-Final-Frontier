extends Area2D

@onready var player : Node2D = null
var permanently_opened = false
@export var chest_contents: Array[Dictionary] = []
var is_ui_open = false


func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	connect("body_exited", Callable(self, "_on_body_exited"))
	$AnimatedSprite2D.play("closed")
	$ChestUI.hide()
	populate_chest()

func _process(delta: float) -> void:
	if overlaps_body(player) and Input.is_action_just_pressed("use"):
		if not permanently_opened:
			$AnimatedSprite2D.play("opening")
			await $AnimatedSprite2D
			$AnimatedSprite2D.play("opened")
			permanently_opened = true
		if is_ui_open:
			close_chest()
		else:
			open_chest()

		
func populate_chest():
	var slots = $ChestUI/GridContainer.get_children()
	for i in range(min(chest_contents.size(), slots.size())):
		var slot = slots[i]
		var item_data = chest_contents[i]
		if "item" in item_data and "amount" in item_data:
			slot.item = item_data["item"]
			slot.set_amount(item_data["amount"])

func open_chest():
	$ChestUI.show()
	is_ui_open = true

func close_chest():
	$ChestUI.hide()
	is_ui_open = false

func _on_body_exited(body):
	if body == player:
		close_chest()
