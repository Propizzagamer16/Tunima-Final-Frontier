extends Area2D

@onready var player : Node2D = null
@onready var chest_ui := get_parent().get_node("ChestUICanvas/ChestUIPopup")
@export var chest_contents: Array[Dictionary] = []
var is_ui_open = false


func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	connect("body_exited", Callable(self, "_on_body_exited"))
	$AnimatedSprite2D.play("closed")
	chest_ui.hide()
	populate_chest()

func _process(delta: float) -> void:
	if overlaps_body(player) and Input.is_action_just_pressed("use"):
		if is_ui_open:
			close_chest()
		else:
			$AnimatedSprite2D.play("opening")
			await $AnimatedSprite2D.animation_finished
			open_chest()

		
func populate_chest():
	var slots = chest_ui.get_node("GridContainer").get_children()
	for i in range(min(chest_contents.size(), slots.size())):
		var slot = slots[i]
		var item_data = chest_contents[i]
		if "item" in item_data and "amount" in item_data:
			slot.item = item_data["item"]
			slot.set_amount(item_data["amount"])


func open_chest():
	chest_ui.populate(chest_contents) # Call a new method on the UI to fill it
	chest_ui.show()
	is_ui_open = true
	$AnimatedSprite2D.play("opened")


func close_chest():
	chest_ui.hide()
	is_ui_open = false
	$AnimatedSprite2D.play("closed")

func _on_body_exited(body):
	if body == player:
		close_chest()
