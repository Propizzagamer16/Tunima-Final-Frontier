extends CharacterBody2D

var fall_speed = 250.0

func _physics_process(delta):
	velocity.y = fall_speed
	move_and_slide()
