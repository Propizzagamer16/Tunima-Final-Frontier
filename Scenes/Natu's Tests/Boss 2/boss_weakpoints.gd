extends Area2D

@onready var animation = $AnimatedSprite2D
var health : int = 60
var can_take_damage = true

func _ready():
	animation.play("default")

func _process(_delta):
	if health <= 0:
		Global.weakpoints_broken += 1
		self.queue_free()


func _on_body_entered(body: Node2D) -> void:
	if Global.player_current_attack == true:
		health = health - 20
		$take_damage_cooldown.start()
		can_take_damage = false


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
