extends Area2D

@export var speed := 800
@export var is_sideview := false  # <- This tells the bullet to move only horizontally
var direction := Vector2.ZERO

func _process(delta):
	if is_sideview:
		position.x += direction.x * speed * delta
	else:
		position += direction.normalized() * speed * delta

func _on_body_entered(body: Node):
	if body.has_method("take_bullet_damage"):
		body.call("take_bullet_damage")
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
