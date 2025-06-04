extends Area2D

@onready var animation = $AnimatedSprite2D
var health: int = 60
var can_take_damage = true

func _ready():
	animation.play("default")

func _process(delta: float) -> void:
	if health <= 0:
			Global.weakpoints_broken += 1
			queue_free()
			
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attacks") or area.is_in_group("player_bullet"):
		if can_take_damage:
			var damage = 20
			health -= damage
			can_take_damage = false
			$take_damage_cooldown.start()
		

func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
