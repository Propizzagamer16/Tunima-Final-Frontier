extends CharacterBody2D

@export var speed := 300
var direction := Vector2.ZERO
var moving := false
var anim_dir
@onready var animation = get_node("AnimatedSprite2D")

func _physics_process(delta):
	match anim_dir:
		"right": animation.play("SideIdle")
		"left": animation.play("SideIdle")
		"up": animation.play("UpIdle")
		"down": animation.play("Idle")
		
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		moving = false
		velocity = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventKey and !moving:
		if event.is_action_pressed("ui_W"):
			anim_dir = "up"
			direction = Vector2.UP
		elif event.is_action_pressed("ui_S"):
			anim_dir = "down"
			direction = Vector2.DOWN
		elif event.is_action_pressed("ui_A"):
			animation.flip_h = true
			anim_dir = "left"
			direction = Vector2.LEFT
		elif event.is_action_pressed("ui_D"):
			animation.flip_h = false
			anim_dir = "right"
			direction = Vector2.RIGHT
		moving = true
