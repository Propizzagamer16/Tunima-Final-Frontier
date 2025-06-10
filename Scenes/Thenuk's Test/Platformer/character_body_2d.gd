extends CharacterBody2D

@export var speed := 300
var direction := Vector2.ZERO
var moving := false

func _physics_process(delta):
	if moving:
		var collision = move_and_collide(direction * speed * delta)
		if collision:
			moving = false
			velocity = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventKey and !moving:
		if event.is_action_pressed("ui_W"):
			direction = Vector2.UP
		elif event.is_action_pressed("ui_S"):
			direction = Vector2.DOWN
		elif event.is_action_pressed("ui_A"):
			direction = Vector2.LEFT
		elif event.is_action_pressed("ui_D"):
			direction = Vector2.RIGHT
		moving = true
