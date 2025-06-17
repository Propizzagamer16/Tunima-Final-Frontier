extends Area2D

@export var speed := 300
var direction = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func _on_area_entered(area):
	if area.name == "player":
		area.take_damage(1)
		queue_free()
