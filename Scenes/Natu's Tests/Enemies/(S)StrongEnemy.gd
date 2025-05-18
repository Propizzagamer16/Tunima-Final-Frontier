extends CharacterBody2D

var speed = 500
var player_chase = false
var player = null

var health = 100
var player_inattack_zone = false
var can_take_damage = true
var player_attack_cooldown = true

@export var gravity = 5000.0
@export var jump_velocity = -1500.0
var can_jump = true


func _physics_process(delta):
	deal_with_damage()
	attack_player()

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Reset vertical velocity when grounded

	# Horizontal chase movement
	if player_chase:
		var direction = sign(player.position.x - position.x)
		velocity.x = direction * speed
	else:
		velocity.x = 0

	handle_jumping()

	move_and_slide()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_chase = false


func enemy():
	pass

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inattack_zone = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			health -= 20
			$take_damage_cooldown.start()
			can_take_damage = false
			if health <= 0:
				self.queue_free()
				
func take_bullet_damage():
	health -= 5
	if health <= 0:
		self.queue_free()

func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true

func attack_player():
	if player_inattack_zone and player_attack_cooldown and player != null:
		if player.is_in_group("player"):
			$do_attack.start()
			player_attack_cooldown = false

func _on_do_attack_timeout() -> void:
	if player_inattack_zone and player != null:
		player.call("take_damage")
		$do_attack.stop()
		player_attack_cooldown = true

func handle_jumping():
	
	var wall_ray_right = $wall_ray_right
	var ground_ray_right = $ground_ray_right
	var wall_ray_left = $wall_ray_left
	var ground_ray_left = $ground_ray_left
	# Only jump if touching the ground
	if is_on_floor():
		var jump_needed = false
		
		if wall_ray_right.is_colliding():
			var collider = wall_ray_right.get_collider()
			if collider and not collider.is_in_group("enemy"):
				jump_needed = true

		if wall_ray_left.is_colliding():
			var collider = wall_ray_left.get_collider()
			if collider and not collider.is_in_group("enemy"):
				jump_needed = true

		if not ground_ray_right.is_colliding() or not ground_ray_left.is_colliding():
			jump_needed = true 

		if jump_needed:
			velocity.y = jump_velocity
			can_jump = false
			$jump_cooldown.start()


func _on_jump_cooldown_timeout() -> void:
	can_jump = true
