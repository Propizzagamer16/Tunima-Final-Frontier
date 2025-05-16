extends Node2D

@export var state: String = "0"

func _ready():
	if state == "0":
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true

func _process(_delta):
	if $Area2D.overlaps_body($"../player") and Input.is_action_just_pressed("use"):
		state = "1" if state == "0" else "0"

	if state == "0":
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true
