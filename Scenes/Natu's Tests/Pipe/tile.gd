extends Area2D

var base_sides: Array[String] = []
var rotation_index := 0
var is_connected := false
var finished = false

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
			base_sides = ["down", "left"]
		"tee":
			base_sides = ["up", "left", "right"]
		"start":
			base_sides = ["down", "right"]
		"end":
			base_sides = ["up", "left"]
		"node":
			base_sides = ["down"]
		_:
			base_sides = []

func _on_input_event(viewport, event, shape_idx):
	var sprite = $AnimatedSprite2D
	var anim_name = sprite.animation
	if event is InputEventMouseButton and event.pressed:
		if anim_name != "start" and anim_name != "end" and finished == false:
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

func set_connected(state: bool):
	is_connected = state
	if state:
		modulate = Color(0.6, 0.6, 1)  
	else:
		modulate = Color(1, 1, 1)
