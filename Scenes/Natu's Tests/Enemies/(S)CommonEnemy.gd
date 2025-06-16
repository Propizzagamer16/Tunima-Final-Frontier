extends CharacterBody2D

var speed = 350
var player_chase = false

var health = 25
var player_inattack_zone = false
var can_take_damage = true
var player_attack_cooldown = true

@onready var player = get_parent().find_child("player")
@export var gravity = 5000.0
@export var jump_velocity = -1500.0
var can_jump = true

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta):
	attack_player()

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Reset vertical velocity when grounded

	# Horizontal chase movement

	var direction = sign(player.position.x - position.x)
	velocity.x = direction * speed

	handle_jumping()
	move_and_slide()
	
	if health <= 0:
		self.queue_free()


func enemy():
	pass

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false

func take_damage(current_damage):
	if can_take_damage == true:
		health = health - current_damage
		$take_damage_cooldown.start()
		can_take_damage = false

func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true

func attack_player():
	if player_inattack_zone and player_attack_cooldown and player != null:
		if player.has_method("take_damage"):
			$do_attack.start()
			player_attack_cooldown = false

func _on_do_attack_timeout() -> void:
	if player_inattack_zone and player != null:
		player.take_damage()
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
