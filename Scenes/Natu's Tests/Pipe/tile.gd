extends Area2D

var base_sides: Array[String] = []
var rotation_index := 0

func _ready():
	assign_sides_from_animation()
	connect("input_event", _on_input_event)

func assign_sides_from_animation():
	var sprite = $AnimatedSprite2D
	var anim_name = sprite.animation

	match anim_name:
		"straight":
			base_sides = ["up", "down"]
		"elbow":
			base_sides = ["up", "right"]
		"tee":
			base_sides = ["up", "left", "right"]
		"cross":
			base_sides = ["up", "right", "down", "left"]
		"end":
			base_sides = ["up"]
		_:
			base_sides = []

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		rotate_tile()

func rotate_tile():
	rotation_index = (rotation_index + 1) % 4
	rotation_degrees = rotation_index * 90

func get_open_sides() -> Array[String]:
	var directions := ["up", "right", "down", "left"]
	var rotated: Array[String] = []

	for side in base_sides:
		var idx = directions.find(side)
		if idx == -1:
			continue
		var rotated_idx = (idx + rotation_index) % 4
		rotated.append(directions[rotated_idx])

	return rotated
