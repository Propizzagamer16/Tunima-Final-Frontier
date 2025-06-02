extends CharacterBody2D
class_name character

const speed = 500.0
const JUMP_VELOCITY = -1100.0

var bullet = preload("res://Assets/Misc/Weapons/bullet.tscn")
@onready var muzzle : Marker2D = $Muzzle
var muzzle_position

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var alive = true

var attack_ip = false
var current_dir = "none"

var hearts_list : Array[TextureRect]

signal player_died

func _ready():
	add_to_group("player")
	ChainGlobal.ChainOverlap.connect(chainOver)

	
	muzzle_position = muzzle.position
	var hearts_parent = $health_bar/HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
		
	get_node("AnimatedSprite2D").play("SideIdle")

func _physics_process(delta: float) -> void:
	if health <= 0:
		health = 0
		die()
		
	delta = 0.04
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_W") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	muzzle_position_update()
	player_movement(delta)
	player_shooting()
	
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
	attack()
	
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

func attack():
	var dir = current_dir
	if Input.is_action_just_pressed("attack"):
		Global.player_current_attack = true
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
	Global.player_current_attack = false
	attack_ip = false

func _on_regen_timer_timeout() -> void:
	if health < 100:
		health += 20
		if health > 100:
			health = 100
	if health <= 0:
		health = 0
	update_hearts()
	
func take_damage():
	if health > 0:
		health -= 20
		update_hearts()
	$regen_timer.start()

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
		
	if health <= 0:
		hearts_list[0].visible = false
	else:
		hearts_list[0].visible = true
func player_shooting():
	var direction : float = Input.get_axis("ui_A", "ui_D")
	
	if Input.is_action_just_pressed("shoot"):
		var bullet_instance = bullet.instantiate() as Node2D
		if direction == 0:
			if current_dir == "right":
				direction = 1
			elif current_dir == "left":
				direction = -1
		
		bullet_instance.direction = Vector2(direction, 0) 
		bullet_instance.is_sideview = true                 
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)

func muzzle_position_update():
	var direction : float = Input.get_axis("ui_A", "ui_D")
	
	if direction < 0:
		muzzle.position.x = -muzzle_position.x
	elif direction > 0:
		muzzle.position.x = muzzle_position.x

func reset(spawn_position: Vector2):
	health = 100
	alive = true
	global_position = spawn_position
	update_hearts()
	$AnimatedSprite2D.play("SideIdle")
	
# In your Player.gd
func die():
	if not alive: 
		return
	alive = false
	emit_signal("player_died")  # Only emits once now
	
func chainOver():
	if ChainGlobal.ChainOverlap:
		velocity.y = -400
