extends Area2D

@export var speed := 800
var direction := Vector2.ZERO

func _process(delta):
	position += direction.normalized() * speed * delta

func _on_body_entered(body: Node):
	if body.has_method("take_bullet_damage"):
		body.call("take_bullet_damage")
	queue_free()  # Destroy bullet on impact

func _on_timer_timeout() -> void:
	queue_free()

func bullet():
	pass
