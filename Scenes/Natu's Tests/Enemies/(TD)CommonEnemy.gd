extends CharacterBody2D

var speed = 100
var player_chase = false
var player = null

var health = 20
var player_inattack_zone = false
var can_take_damage = true
var player_attack_cooldown = true

func _physics_process(delta):
	deal_with_damage()
	
	if player_chase and player:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()



func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false

func enemy():
	pass



func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			health -= 20
			can_take_damage = false
			Global.player_current_attack = false
			$take_damage_cooldown.start()
			if health <= 0:
				self.queue_free()


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
		

func attack_player():
	if player_inattack_zone and player_attack_cooldown and player != null:
		if player.has_method("take_damage"):
			player.call("take_damage")
			player_attack_cooldown = false
			$do_attack.start()

	
func _on_do_attack_timeout() -> void:
	$do_attack.stop()
	player_attack_cooldown = true
