extends CharacterBody2D

func _ready():
	get_node("AnimatedSprite2D").play("Idle")

###4D MOVEMENT
@export var movement_speed: float = 500
var character_direction := Vector2.ZERO

func _physics_process(_delta):
	character_direction.x = Input.get_axis("ui_left", "ui_right")
	character_direction.y = Input.get_axis("ui_up", "ui_down")

	if character_direction != Vector2.ZERO:
		character_direction = character_direction.normalized()
		velocity = character_direction * movement_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		_ready()

	move_and_slide()
