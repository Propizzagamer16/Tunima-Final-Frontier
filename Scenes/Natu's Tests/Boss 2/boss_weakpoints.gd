extends Area2D

@onready var animation = $AnimatedSprite2D
var health : int = 60
var can_take_damage = true
var player_inside = false

func _ready():
	animation.play("default")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_inside = false

func _process(_delta):
	if player_inside and Global.player_current_attack and can_take_damage:
		print("damage taken")
		health -= 20
		can_take_damage = false
		$take_damage_cooldown.start()

	if health <= 0:
		Global.weakpoints_broken += 1
		queue_free()


func _on_take_damage_cooldown_timeout() -> void:
	print("cooldown in play")
	can_take_damage = true
