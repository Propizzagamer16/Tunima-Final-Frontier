extends Area2D

@export var speed = 1000
@export var direction = Vector2.RIGHT
@export var damage = 100

func _ready():
	$delete_bullet.start()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	position += direction.normalized() * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
	queue_free()

func _on_delete_bullet_timeout():
	queue_free()
