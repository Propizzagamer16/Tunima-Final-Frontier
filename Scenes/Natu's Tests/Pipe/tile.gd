extends Area2D

@export var open_sides: Array[String] = []
var rotation_index := 0  # 0-3

func _ready():
	connect("input_event", _on_input_event)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		rotate_tile()

func rotate_tile():
	rotation_index = (rotation_index + 1) % 4
	rotation_degrees = rotation_index * 90
	open_sides = rotated_sides()

func rotated_sides() -> Array[String]:
	var directions = ["up", "right", "down", "left"]
	var rotated = []
	for side in open_sides:
		var idx = (directions.find(side) + rotation_index) % 4
		rotated.append(directions[idx])
	return rotated
