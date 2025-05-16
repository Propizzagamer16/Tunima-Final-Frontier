extends Area2D

var speed : int = 600
var direction : int

func _process(delta):
	position.x += direction * speed * delta

func _on_body_entered(body: Node):
	if body.has_method("take_bullet_damage"):
		body.call("take_bullet_damage")
	queue_free()  # Destroy bullet on impact

func _physics_process(delta: float) -> void:
	move_local_x(direction * speed * delta)

func _on_timer_timeout() -> void:
	queue_free()

func bullet():
	pass
