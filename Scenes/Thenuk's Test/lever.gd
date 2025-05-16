extends Node2D

@export var state: String = "0"

func _ready():
	if state == "0":
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true

func _process(_delta):
	if $Area2D.overlaps_body($"../player") and Input.is_action_just_pressed("use"):
		if state == "0":
			state = "1"
		else:
			state = "0"
		LeverGobal.leverChanged()

	if state == "0":
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true
