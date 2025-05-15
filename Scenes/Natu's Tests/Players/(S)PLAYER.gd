extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -1300.0


var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var alive = true

var attack_ip = false
var current_dir = "none"

var hearts_list : Array[TextureRect]

func _ready():
	get_node("AnimatedSprite2D").play("Idle")

func _physics_process(delta: float) -> void:
	delta = 0.04
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_W") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_A", "ui_D")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		_ready()
	
	move_and_slide()
	enemy_attacks(delta)
	attack()
	#update_health()
	
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
	hearts_list[0].visible = hearts_to_show >= 1
	hearts_list[1].visible = hearts_to_show >= 2
	hearts_list[2].visible = hearts_to_show >= 3
	hearts_list[3].visible = hearts_to_show >= 4
	hearts_list[4].visible = hearts_to_show >= 5

	# Optional: heartbeat animation on last heart
	if hearts_to_show == 1:
		hearts_list[0].get_child(0).play("Beating")
	else:
		hearts_list[0].get_child(0).play("Idle")
