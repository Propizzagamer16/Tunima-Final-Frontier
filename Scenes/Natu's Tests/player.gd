extends CharacterBody2D

###2D MOVEMENT

#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
#
func _ready():
	get_node("AnimatedSprite2D").play("Idle")
#

#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()

###4D MOVEMENT
@export var movement_speed: float = 500
var character_direction := Vector2.ZERO

func _physics_process(delta):
	character_direction.x = Input.get_axis("ui_left", "ui_right")
	character_direction.y = Input.get_axis("ui_up", "ui_down")

	if character_direction != Vector2.ZERO:
		character_direction = character_direction.normalized()
		velocity = character_direction * movement_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		_ready()

	move_and_slide()
