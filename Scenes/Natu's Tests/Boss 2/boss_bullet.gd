extends Area2D

@export var speed: float = 700
var direction: Vector2 = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	rotation = direction.angle()
	sprite.play("fly")

func _physics_process(delta):
	position += direction.normalized() * speed * delta


func _on_body_entered(body: Node):
	if body.has_method("take_ten_damage"):
		body.call("take_ten_damage")
	queue_free()
