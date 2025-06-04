extends Area2D

@export var speed := 1400
@export var is_sideview := false
var direction := Vector2.ZERO
var damage = 10

func _process(delta):
	if is_sideview:
		position.x += direction.x * speed * delta
	else:
		position += direction.normalized() * speed * delta

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		return
		
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
