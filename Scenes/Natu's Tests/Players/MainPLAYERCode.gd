extends CharacterBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var max_health = 100
var alive = true
var base_damage: int = 20
var current_damage: int = base_damage
var side_view = false
var top_down = false
var gravitydelta = 0.04
var attack_ip = false
var current_dir = "none"
var speed = 700
var JUMP_VELOCITY = -1100.0
var active_boosts = {}
var powerup_cooldowns: Dictionary = {
	"speed": 0.0,
	"strength": 0.0,
	"firerate": 0.0,
	"health": 0.0
}

@onready var attack_hitbox := $attack_range_hori

var bullet = preload("res://Assets/Misc/Weapons/bullet.tscn")
var power = preload("res://Assets/Misc/Weapons/Ult_Bullet.tscn")
@onready var muzzle : Marker2D = $Muzzle
var muzzle_position

var hearts_list : Array[TextureRect]
signal player_died


func _ready():
	set_mode_from_global()
	add_to_group("player")
	attack_hitbox.add_to_group("player_attacks")

	ChainGlobal.ChainOverlap.connect(chainOver)
	JumpPadGlobal.jumpOverlap.connect(jumpPad)
	
	var hotbar_ui = get_node("Inventory/UI/Hotbar")
	hotbar_ui.visible = true
	muzzle_position = muzzle.position
	var hearts_parent = $health_bar/HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
		
	get_node("AnimatedSprite2D").play("Idle")


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
	player_movement(gravitydelta)
	attack()
	#deal_damage()


func set_mode_from_global():
	if Global.player_type == "Top Down":
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		top_down = true
		side_view = false
	elif Global.player_type == "Side":
		motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
		top_down = false
		side_view = true

func set_camera(current_scene):	
	if current_scene == "platformer":
		$Camera2D.limit_left = -128
		$Camera2D.limit_right = 26111
		$Camera2D.limit_top = -3000.0
		$Camera2D.limit_bottom = 1790
	elif current_scene == "weapons_lab":
		$Camera2D.limit_left = 0
		$Camera2D.limit_right = 1910.0
		$Camera2D.limit_top = 0
		$Camera2D.limit_bottom = 1152.0
	elif current_scene == "boss_2":
		$Camera2D.zoom = Vector2(0.5, 0.5)
		$Camera2D.drag_horizontal_enabled = false
		$Camera2D.drag_vertical_enabled = false
		$Camera2D.limit_left = -10000000
		$Camera2D.limit_right = 1000000
		$Camera2D.limit_top = -1000000
		$Camera2D.limit_bottom = 10000000
	#ILL ADD MORE WHEN WE MAKE MORE/WHEN IMAAD FINISHES DUNGEON
	
func player_movement(gravity):	
	if side_view:
		if not is_on_floor():
			velocity += get_gravity() * gravity
		if Input.is_action_just_pressed("ui_W") and is_on_floor():
			velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("ui_D"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		if top_down:
			velocity.y = 0
	elif Input.is_action_pressed("ui_A"):
		play_anim(1)
		current_dir = "left"
		velocity.x = -speed
		if top_down:
			velocity.y = 0
	elif Input.is_action_pressed("ui_S") and top_down:
		play_anim(1)
		current_dir = "down"
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_W") and top_down:
		play_anim(1)
		current_dir = "up"
		velocity.x = 0
		velocity.y = -speed
	else:
		play_anim(0)
		velocity.x = 0
		if top_down:
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
			
	if dir == "up" and top_down:
		if attack_ip == false:
			if movement == 1:
				anim.play("UpWalk")
			elif movement == 0:
				if attack_ip == false:
					anim.play("UpIdle")
			
	if dir == "down" and top_down:
		if attack_ip == false:
			if movement == 1:
				anim.play("DownWalk")
			elif movement == 0:
				if attack_ip == false:
					anim.play("Idle")

##ATTACK
func player():
	pass

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func attack():
	var dir = current_dir
	if Input.is_action_just_pressed("attack"):
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("SideAttack")
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("SideAttack")
		if dir == "down" and top_down:
			$AnimatedSprite2D.play("DownAttack")
		if dir == "up" and top_down:
			$AnimatedSprite2D.play("UpAttack")
		
		update_attack_hitbox_position(dir)

		attack_hitbox.monitoring = true
		$deal_attack.start() 

		
func update_attack_hitbox_position(dir: String):
	match dir:
		"right": attack_hitbox.position = Vector2(40, 0)
		"left": attack_hitbox.position = Vector2(-40, 0)
		"up": attack_hitbox.position = Vector2(0, -60)
		"down": attack_hitbox.position = Vector2(0, 60)


func _on_attack_range_hori_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and attack_hitbox.monitoring:
		if body.has_method("take_damage"):
			body.take_damage(current_damage)

func _on_deal_attack_timeout() -> void:
	attack_ip = false
	attack_hitbox.monitoring = false


func take_damage():
	if health >= 0:
		health -= 20
		update_hearts()
		
func take_ten_damage():
	if health >= 0:
		health -= 10
		update_hearts()

func update_hearts():
	var hearts_full = int(health / 20)
	var remainder = int(health) % 20
	var has_half_heart = remainder >= 10

	for i in range(hearts_list.size()):
		var heart_sprite = hearts_list[i].get_child(0)

		if i < hearts_full:
			heart_sprite.visible = true
			heart_sprite.play("Full")
		elif i == hearts_full and has_half_heart:
			heart_sprite.visible = true
			heart_sprite.play("Half")
		else:
			heart_sprite.visible = false


	if hearts_full == 1 and not has_half_heart:
		hearts_list[0].get_child(0).play("Beating")
	elif hearts_full == 0 and has_half_heart:
		hearts_list[0].get_child(0).play("Half_beating")
	else:
		hearts_list[0].get_child(0).play("Full")

func player_shooting():
	var xdirection: float = Input.get_axis("ui_A", "ui_D")
	var ydirection: float = Input.get_axis("ui_W", "ui_S")

	if Input.is_action_just_pressed("shoot"):
		var bullet_instance = bullet.instantiate() as Node2D
		if top_down:
			var dir = Vector2(xdirection, ydirection)
			if dir == Vector2.ZERO:
				match current_dir:
					"right": dir = Vector2.RIGHT
					"left": dir = Vector2.LEFT
					"up": dir = Vector2.UP
					"down": dir = Vector2.DOWN
			bullet_instance.direction = dir
			bullet_instance.is_sideview = false
		elif side_view:
			if xdirection == 0:
				if current_dir == "right":
					xdirection = 1
				elif current_dir == "left":
					xdirection = -1
			bullet_instance.direction = Vector2(xdirection, 0)
			bullet_instance.is_sideview = true

		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)

func heavy_bullet():
	var xdirection: float = Input.get_axis("ui_A", "ui_D")
	var ydirection: float = Input.get_axis("ui_W", "ui_S")

	if Input.is_action_just_pressed("power_shot"):
		var power_instance = power.instantiate() as Node2D
		if top_down:
			var dir = Vector2(xdirection, ydirection)
			if dir == Vector2.ZERO:
				match current_dir:
					"right": dir = Vector2.RIGHT
					"left": dir = Vector2.LEFT
					"up": dir = Vector2.UP
					"down": dir = Vector2.DOWN
			power_instance.direction = dir
			power_instance.is_sideview = false
		elif side_view:
			if xdirection == 0:
				if current_dir == "right":
					xdirection = 1
				elif current_dir == "left":
					xdirection = -1
			power_instance.direction = Vector2(xdirection, 0)
			power_instance.is_sideview = true

		power_instance.global_position = muzzle.global_position
		get_parent().add_child(power_instance)

func muzzle_position_update():
	if top_down:
		match current_dir:
			"right":
				muzzle.position = Vector2(40, 0)
			"left":
				muzzle.position = Vector2(-40, 0)
			"up":
				muzzle.position = Vector2(0, -50)
			"down":
				muzzle.position = Vector2(0, 55)
	elif side_view:
		var direction : float = Input.get_axis("ui_A", "ui_D")
		if direction < 0:
			muzzle.position.x = -muzzle_position.x
		elif direction > 0:
			muzzle.position.x = muzzle_position.x

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
			$deal_attack.wait_time = 0.2
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

func chainOver():
	if ChainGlobal.ChainOverlap:
		velocity.y = -400

func jumpPad():
	if JumpPadGlobal.jumpOverlap:
		velocity.y = -3000
