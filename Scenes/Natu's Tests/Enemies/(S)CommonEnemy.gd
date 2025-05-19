extends CharacterBody2D

var speed = 350
var player_chase = false
var player = null

var health = 25
var player_inattack_zone = false
var can_take_damage = true
var player_attack_cooldown = true

@export var gravity = 5000.0
@export var jump_velocity = -1500.0
var can_jump = true

@export var dude = Node2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta):
	if dude != null:
		nav_agent.target_position = dude.global_position

	if nav_agent.is_navigation_finished():
		velocity.x = 0
	else:
		var next_path_point = nav_agent.get_next_path_position()
		var direction = (next_path_point - global_position).normalized()
		velocity.x = direction.x * speed
		
	move_and_slide()
	#handle_jumping()
	#deal_with_damage()
	#attack_player()
		
func make_path() -> void:
	nav_agent.target_position = dude.global_position

func _on_make_path_timeout() -> void:
	make_path()

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
	if body.has_method("player"):
		player_inattack_zone = true

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
				
func take_bullet_damage():
	health -= 5
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
