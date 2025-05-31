extends CharacterBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var max_health = 100
var alive = true
var base_damage: int = 20
var current_damage: int = base_damage


var attack_ip = false
var current_dir = "none"
var speed = 700
var active_boosts = {}
var powerup_cooldowns: Dictionary = {
	"speed": 0.0,
	"strength": 0.0,
	"firerate": 0.0,
	"health": 0.0
}


var bullet = preload("res://Assets/Misc/Weapons/bullet.tscn")
@onready var muzzle : Marker2D = $Muzzle
var muzzle_position

var hearts_list : Array[TextureRect]
signal player_died
#
func _ready():
	var hotbar_ui = get_node("Inventory/UI/Hotbar")
	hotbar_ui.visible = true
	muzzle_position = muzzle.position
	var hearts_parent = $health_bar/HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
		
	get_node("AnimatedSprite2D").play("Idle")

###4D MOVEMENT
var character_direction := Vector2.ZERO


func _process(delta):
	for key in powerup_cooldowns.keys():
		if powerup_cooldowns[key] > 0:
			powerup_cooldowns[key] -= delta

func _physics_process(delta):
	for key in powerup_cooldowns.keys():
		if powerup_cooldowns[key] > 0:
			powerup_cooldowns[key] = max(0, powerup_cooldowns[key] - delta)

	if health <= 0 and alive:
		alive = false
		health = 0
		hide()
		set_physics_process(false)
		emit_signal("player_died")

	muzzle_position_update()
	player_shooting()
	player_movement()
	attack()
	deal_damage()
	
func player_movement():	
	
	if Input.is_action_pressed("ui_D"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_A"):
		play_anim(1)
		current_dir = "left"
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_S"):
		play_anim(1)
		current_dir = "down"
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_W"):
		play_anim(1)
		current_dir = "up"
		velocity.x = 0
		velocity.y = -speed
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0

	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if attack_ip == false:
			if movement == 1:
				anim.play("SideWalk")
			elif movement == 0:
				if attack_ip == false:
					anim.play("SideIdle")
				
	if dir == "left":
		anim.flip_h = true
		if attack_ip == false:
			if movement == 1:
				anim.play("SideWalk")
			elif movement == 0:
				if attack_ip == false:
					anim.play("SideIdle")
			
	if dir == "up":
		if attack_ip == false:
			if movement == 1:
				anim.play("UpWalk")
			elif movement == 0:
				if attack_ip == false:
					anim.play("UpIdle")
			
	if dir == "down":
		if attack_ip == false:
			if movement == 1:
				anim.play("DownWalk")
			elif movement == 0:
				if attack_ip == false:
					anim.play("Idle")

##ATTACK
func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func attack():
	var dir = current_dir
	if Input.is_action_just_pressed("attack"):
		Global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("SideAttack")
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("SideAttack")
		if dir == "down":
			$AnimatedSprite2D.play("DownAttack")
		if dir == "up":
			$AnimatedSprite2D.play("UpAttack")
		$deal_attack.start()
		
func deal_damage():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("take_damage") and Global.player_current_attack:
			enemy.take_damage(current_damage)

func _on_deal_attack_timeout() -> void:
	Global.player_current_attack = false
	attack_ip = false

func take_damage():
	if health >= 0:
		health -= 20
		update_hearts()
		
func take_ten_damage():
	if health >= 0:
		health -= 10
		update_hearts()

func update_hearts():
	var hearts_to_show = int(health / 20) 

	# Hide or show each heart manually
	hearts_list[0].visible = hearts_to_show >= 0.5
	hearts_list[1].visible = hearts_to_show >= 2
	hearts_list[2].visible = hearts_to_show >= 3
	hearts_list[3].visible = hearts_to_show >= 4
	hearts_list[4].visible = hearts_to_show >= 5
	if hearts_to_show == 1:
		hearts_list[0].get_child(0).play("Beating")
	else:
		hearts_list[0].get_child(0).play("Idle")

func player_shooting():
	var xdirection: float = Input.get_axis("ui_A", "ui_D")
	var ydirection: float = Input.get_axis("ui_W", "ui_S")

	if Input.is_action_just_pressed("shoot"):
		var bullet_instance = bullet.instantiate() as Node2D
		var dir = Vector2(xdirection, ydirection)
		
		if dir == Vector2.ZERO:
			match current_dir:
				"right": dir = Vector2.RIGHT
				"left": dir = Vector2.LEFT
				"up": dir = Vector2.UP
				"down": dir = Vector2.DOWN

		bullet_instance.direction = dir
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)


func muzzle_position_update():
	match current_dir:
		"right":
			muzzle.position = Vector2(40, 0)
		"left":
			muzzle.position = Vector2(-40, 0)
		"up":
			muzzle.position = Vector2(0, -50)
		"down":
			muzzle.position = Vector2(0, 55)

func _unhandled_input(event):
	if Input.is_action_just_pressed("inventory"):
		var inventory_ui = get_node("Inventory/UI/InventoryUI")
		inventory_ui.visible = not inventory_ui.visible
		var weapon_ui = get_node("Inventory/UI/weapon_upgrade")
		weapon_ui.visible = not weapon_ui.visible


func apply_power_up(stat: String, amount: float, duration: float, cooldown: float) -> void:
	if powerup_cooldowns[stat] > 0 or active_boosts.has(stat):
		return

	powerup_cooldowns[stat] = cooldown 

	match stat:
		"speed":
			print("speed acitvated")
			speed += amount
			active_boosts["speed"] = amount
			await get_tree().create_timer(duration).timeout
			speed -= amount
			active_boosts.erase("speed")

		"firerate":
			print("firerate acitvated")
			active_boosts["firerate"] = amount
			$deal_attack.wait_time = 0.1
			$AnimatedSprite2D.speed_scale = 2.0
			await get_tree().create_timer(duration).timeout
			$AnimatedSprite2D.speed_scale = 1.0
			$deal_attack.wait_time = 0.5
			active_boosts.erase("firerate")

		"strength":
			print("strength acitvated")
			current_damage += amount
			active_boosts["strength"] = amount
			await get_tree().create_timer(duration).timeout
			current_damage -= amount
			active_boosts.erase("strength")

		"health":
			print("health acitvated")
			health = min(health + amount, max_health)
			update_hearts()

func reset(spawn_position: Vector2):
	health = 100
	alive = true
	global_position = spawn_position
	update_hearts()
	$AnimatedSprite2D.play("SideIdle")
	show()
	set_physics_process(true)
