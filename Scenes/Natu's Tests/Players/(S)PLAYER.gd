extends CharacterBody2D

const speed = 500.0
const JUMP_VELOCITY = -1300.0


var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var alive = true

var attack_ip = false
var current_dir = "none"

var hearts_list : Array[TextureRect]

func _ready():
	var hearts_parent = $health_bar/HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
		
	get_node("AnimatedSprite2D").play("Idle")

func _physics_process(delta: float) -> void:
	
	if health <= 0:
		alive = false
		health = 0
		self.queue_free()
		
	delta = 0.04
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_W") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	player_movement(delta)
	
func player_movement(delta):	
	
	if Input.is_action_pressed("ui_D"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
	elif Input.is_action_pressed("ui_A"):
		play_anim(1)
		current_dir = "left"
		velocity.x = -speed
	else:
		play_anim(0)
		velocity.x = 0

	move_and_slide()
	enemy_attacks(delta)
	attack()
	test_dmg()
	
func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if attack_ip == false:
			if movement == 1:
				anim.play("SideWalk")
			elif movement == 0:
				anim.play("SideIdle")
				
	if dir == "left":
		anim.flip_h = true
		if attack_ip == false:
			if movement == 1:
				anim.play("SideWalk")
			elif movement == 0:
				anim.play("SideIdle")

	#ATTACK
func player():
		pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attacks(delta):
	if enemy_inattack_range and enemy_attack_cooldown:
		take_damage()
		enemy_attack_cooldown = false
		$attack_cooldown.start()

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func attack():
	var dir = current_dir
	if Input.is_action_just_pressed("attack"):
		Global.current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("SideAttack")
			$deal_attack.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("SideAttack")
			$deal_attack.start()

func _on_deal_attack_timeout() -> void:
	$deal_attack.stop()
	Global.current_attack = false
	attack_ip = false

func _on_regen_timer_timeout() -> void:
	if health <= 100:
		health += 20
		if health > 100:
			health = 100
	if health <= 0:
		health = 0

func take_damage():
	if health > 0:
		health -= 20
		update_hearts()
		

func update_hearts():
	var hearts_to_show = int(health / 20)  # Still needed

	# Hide or show each heart manually
	hearts_list[1].visible = hearts_to_show >= 2
	hearts_list[2].visible = hearts_to_show >= 3
	hearts_list[3].visible = hearts_to_show >= 4
	hearts_list[4].visible = hearts_to_show >= 5

	 #Optional: heartbeat animation on last heart
	if hearts_to_show == 1:
		hearts_list[0].get_child(0).play("Beating")
	else:
		hearts_list[0].get_child(0).play("Idle")

func test_dmg():
	if Input.is_action_just_pressed("ui_S"):
		take_damage()
