extends CharacterBody2D

var godmode = false
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var max_health = 100
var alive = true
var current_damage: int = 20
var power_shot = true
var can_shoot_bullet = true
var attacking = false
var side_view = false
var top_down = false
var gravitydelta = 0.04
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

#variable jump stuff
const MAX_JUMP_HOLD_TIME = 0.5
var JUMP_FORCE = -1400.0
const JUMP_CUTOFF = 0.8
var GRAVITY = 3000.0
var is_jumping = false
var jump_time = 0.0


#dashing stuff
var can_dash = true
var is_dashing = false
var dash_speed = 15000
var dash_duration = 0.1
var dash_cooldown = 1.0

var bullet = preload("res://Assets/Misc/Weapons/bullet.tscn")
var power = preload("res://Assets/Misc/Weapons/Ult_Bullet.tscn")
@onready var muzzle : Marker2D = $Muzzle
var muzzle_position

var current_chest: Area2D = null
var hearts_list : Array[TextureRect]
signal player_died

func _ready():
	if Global.GOD_MODE:
		godmode = true
		current_damage = 300
		
	set_mode_from_global()
	add_to_group("player")
	#attack_hitbox.add_to_group("player_attacks")

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
	
	if not is_dashing:
		player_movement(delta)

func set_mode_from_global():
	if Global.player_type == "Top Down" or godmode:
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
		$Camera2D.zoom = Vector2(1, 1)
		#$Camera2D.drag_horizontal_enabled = false
		#$Camera2D.drag_vertical_enabled = false
		$Camera2D.limit_left = 0
		$Camera2D.limit_right = 1910
		$Camera2D.limit_top = 0
		$Camera2D.limit_bottom = 1080
	#ILL ADD MORE WHEN WE MAKE MORE/WHEN IMAAD FINISHES DUNGEON
	elif current_scene == "(S) Dungeon":
		$Camera2D.zoom = Vector2(6.5, 6.5)
		$Camera2D.limit_left = -1000
		$Camera2D.limit_right = 1000
		$Camera2D.limit_top = -1000
		$Camera2D.limit_bottom = 3000
	elif current_scene == "Verdigris Phase 1":
		$Camera2D.limit_left = 0
		$Camera2D.limit_right = 1910
		$Camera2D.limit_top = -300
		$Camera2D.limit_bottom = 1100
	elif current_scene == "Introduction":
		$Camera2D.zoom = Vector2(2, 2)
		$Camera2D.limit_left = -50
		$Camera2D.limit_right = 1715
		$Camera2D.limit_top = 250
		$Camera2D.limit_bottom = 1320
		
	
func player_movement(delta):	
	if side_view:
		if Input.is_action_just_pressed("ui_W") and is_on_floor():
			velocity.y = JUMP_FORCE
			is_jumping = true
			jump_time = 0.0 

		if is_jumping:
			jump_time += delta
			if Input.is_action_just_released("ui_W"):
				if velocity.y < 0:
					velocity.y *= JUMP_CUTOFF
				is_jumping = false
			if jump_time > MAX_JUMP_HOLD_TIME:
				is_jumping = false

# Apply gravity if in air
		if not is_on_floor():
			velocity.y += GRAVITY * delta

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
	elif Input.is_action_pressed("ui_S"):
		current_dir = "down"
		if top_down:
			velocity.x = 0
			velocity.y = speed
			play_anim(1)  # Only play once

	elif Input.is_action_pressed("ui_W"):
		current_dir = "up"
		if top_down:
			play_anim(1)
			velocity.x = 0
			velocity.y = -speed
		elif side_view:
			velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		if top_down:
			velocity.y = 0

	move_and_slide()

func start_dash():
	is_dashing = true
	can_dash = false

	var dash_direction = Vector2.ZERO
	match current_dir:
		"right": dash_direction = Vector2.RIGHT
		"left": dash_direction = Vector2.LEFT
		"up": dash_direction = Vector2.UP
		"down": dash_direction = Vector2.DOWN

	if side_view:
		dash_direction.y = 0

	velocity = dash_direction * dash_speed
	move_and_slide()
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

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
			if movement == 1 and top_down:
				anim.play("UpWalk")
			elif movement == 0:
				anim.play("UpIdle")
					
			
	if dir == "down":
		if attack_ip == false:
			if movement == 1 and top_down:
				anim.play("DownWalk")
			elif movement == 0:
				anim.play("Idle")

##ATTACK
func player():
	pass

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func attack():
	if attacking:
		return
	attacking = true
	attack_ip = true
	$deal_attack.start()
	
	shake_camera(0.2, 2.0)


	var anim = $AnimatedSprite2D
	match current_dir:
		"right":
			anim.flip_h = false
			anim.play("SideAttack")
		"left":
			anim.flip_h = true
			anim.play("SideAttack")
		"down":
			anim.play("DownAttack")
		"up":
			anim.play("UpAttack")
	
	update_attack_range_position(current_dir)

	var overlapping_areas = $attack_range_hori.get_overlapping_areas()
	for area in overlapping_areas:
		var parent = area.get_parent()
		if parent.has_method("take_damage"):
			parent.take_damage(current_damage)

	# Reset attack after animation duration
	await anim.animation_finished
	attacking = false
	attack_ip = false


func update_attack_range_position(current_dir):
	match current_dir:
		"right": $attack_range_hori.position = Vector2(40, 0)
		"left": $attack_range_hori.position = Vector2(-40, 0)
		"up": $attack_range_hori.position = Vector2(0, -40)
		"down": $attack_range_hori.position = Vector2(0, 40)

func take_damage():
	if health >= 0 and !godmode:
		health -= 20
		update_hearts()
		
func take_ten_damage():
	if health >= 0 and !godmode:
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

	if Input.is_action_just_pressed("shoot") and can_shoot_bullet:
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
		can_shoot_bullet = false
		$bullet_cooldown.start()

func _on_bullet_cooldown_timeout() -> void:
	can_shoot_bullet = true

func heavy_bullet():
	var xdirection: float = Input.get_axis("ui_A", "ui_D")
	var ydirection: float = Input.get_axis("ui_W", "ui_S")

	if Input.is_action_just_pressed("power_shot"):
		shake_camera(0.4, 12.0)
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
		power_shot = false
		$power_cooldown.start()
		
func _on_power_cooldown_timeout() -> void:
	power_shot = true
	
func muzzle_position_update():
	if top_down:
		match current_dir:
			"right":
				muzzle.position = Vector2(100, 0)
			"left":
				muzzle.position = Vector2(-100, 0)
			"up":
				muzzle.position = Vector2(0, -100)
			"down":
				muzzle.position = Vector2(0, 100)
	elif side_view:
		var direction : float = Input.get_axis("ui_A", "ui_D")
		if direction < 0:
			muzzle.position.x = -muzzle_position.x
		elif direction > 0:
			muzzle.position.x = muzzle_position.x

func _unhandled_input(event):
	if Input.is_action_just_pressed("attack"):
		attack()
	
	if Input.is_action_just_pressed("power_shot") and power_shot:
		heavy_bullet()
		
	if Input.is_action_just_pressed("shoot") and can_shoot_bullet:
		player_shooting()
	
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		start_dash()

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


func shake_camera(duration := 0.2, intensity := 5.0):
	var timer := 0.0
	var camera := $Camera2D
	
	while timer < duration:
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		camera.offset = offset
		await get_tree().process_frame
		timer += get_process_delta_time()
	
	camera.offset = Vector2.ZERO


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
		velocity.y = -450

func jumpPad():
	if JumpPadGlobal.jumpOverlap:
		velocity.y = -3000

func open_chest_ui(chest: Area2D):
	var chest_ui = preload("res://Scenes/Natu's Tests/chests/chest_UI.tscn").instantiate()
	chest_ui.chest_inventory = chest.chest_inventory
	chest_ui.player_inventory = $InventoryManager.inventory
	get_tree().current_scene.add_child(chest_ui)
