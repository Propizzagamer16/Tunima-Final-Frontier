extends Area2D

@export var speed = 400
@export var direction = Vector2.RIGHT
@export var is_sideview := false
@export var damage = 100

func _ready():
	add_to_group("player_power")
	$delete_bullet.start()
	rotation = direction.angle()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	if is_sideview:
		position.x += direction.x * speed * delta
	else:
		position += direction.normalized() * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()

func _on_delete_bullet_timeout():
	queue_free()
