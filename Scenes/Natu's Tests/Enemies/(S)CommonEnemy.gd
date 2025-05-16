extends CharacterBody2D


var speed = 150
var player_chase = false
var player = null

var health = 20
var player_inattack_zone = false
var can_take_damage = true
var player_attack_cooldown = true

func _physics_process(delta):
	deal_with_damage()
	attack_player()

	if player_chase:
		var direction = sign(player.position.x - position.x)
		velocity.x = direction * speed
	else:
		velocity.x = 0
	
	# Use move_and_slide to keep physics interactions (like collision and gravity)
	move_and_slide()
	


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
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
	
	if body.has_method("bullet"):
		health -= 5

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			health -= 20
			$take_damage_cooldown.start()
			can_take_damage = false
			if health <= 0:
				self.queue_free()


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true

func attack_player():
	if player_inattack_zone and player_attack_cooldown and player != null:
		if player.has_method("take_damage"):
			$do_attack.start()
			player_attack_cooldown = false
			

	
func _on_do_attack_timeout() -> void:
	if player_inattack_zone and player != null:
		player.call("take_damage")
		$do_attack.stop()
		player_attack_cooldown = true
