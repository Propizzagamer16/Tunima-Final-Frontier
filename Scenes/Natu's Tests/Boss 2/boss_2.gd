extends CharacterBody2D

@onready var player = get_parent().find_child("player")
@onready var animated_sprite = $AnimatedSprite2D
@onready var progress_bar = $CanvasLayer/ProgressBar
@export var projectile_scene: PackedScene
@export var weakpoints_scene: PackedScene
@onready var chest = get_parent().get_node("Chest")
var current_weakpoint: Node2D = null
var godmode = false
var direction : Vector2
var player_inattack_zone = false
var can_take_damage = true
var can_attack = false
var can_teleport = true
var is_vulnerable = false
var dist_before_teleporting : float = 450

var health: = 500:
	set(value):
		health = value
		progress_bar.value = value
		if value <= 0:
			progress_bar.visible = false
			chest.position = self.position
			chest.visible = true
			self.queue_free()

func _ready():
	if Global.GOD_MODE:
		godmode = true
		
	add_to_group("enemies")
	add_to_group("boss_2")
	set_physics_process(false)
	Global.weakpoints_broken = 0
	$weakpoints_spawns.start()
	$starting_timer.start()


func _process(_delta):
	player_firerate()
	low_health()
		
	if Global.weakpoints_broken >= 3 and not is_vulnerable:
		is_vulnerable = true
		can_attack = false
		can_teleport = false
		$vulnerable_timer.start()

	if not is_vulnerable and player:
		direction = player.position - position
		if direction.x > 0:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false

		var dist = position.distance_to(player.position)
		if dist < dist_before_teleporting and can_teleport and !godmode:
			teleport_away(8)
		elif can_attack:
			attack_player()
	
	if is_vulnerable:
		animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	velocity = direction.normalized() * 40
	move_and_collide(velocity * delta)
	
func take_damage(current_damage):
	if can_take_damage == true:
		health = health - current_damage
		$take_damage_cooldown.start()
		can_take_damage = false

func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
		
func teleport_away(attempts):
	var arena_rect = Rect2(Vector2(150, 150), Vector2(1620, 780))
	var best_pos = global_position
	var max_distance = 0.0

	for i in range(attempts):
		var angle = TAU * i / attempts #gets 'attempts' number of diff angles
		var offset = Vector2.RIGHT.rotated(angle) * 900
		var candidate = global_position + offset

		candidate.x = clamp(candidate.x, arena_rect.position.x, arena_rect.position.x + arena_rect.size.x)
		candidate.y = clamp(candidate.y, arena_rect.position.y, arena_rect.position.y + arena_rect.size.y)

		var dist = candidate.distance_to(player.global_position)
		if dist > max_distance:
			max_distance = dist
			best_pos = candidate

	global_position = best_pos

func shoot_projectile_at_player():
	var bullet = projectile_scene.instantiate()
	var shoot_dir = (player.position - position).normalized()
	var spawn_offset = shoot_dir * 250 
	bullet.global_position = global_position + spawn_offset
	bullet.direction = shoot_dir
	get_parent().add_child(bullet)


func attack_player():
	if can_attack:
		can_attack = false
		shoot_projectile_at_player()
		$attack_cooldown.start()
		animated_sprite.play("attacking")

func _on_attack_cooldown_timeout():
	can_attack = true
	
#func _on_hitbox_body_entered(body: Node2D) -> void:
	#if body.name == "player":
		#player_inattack_zone = true
#
#func _on_hitbox_body_exited(body: Node2D) -> void:
	#if body.name == "player":
		#player_inattack_zone = false

func _on_weakpoints_spawns_timeout():
	if current_weakpoint != null and current_weakpoint.is_inside_tree():
		return

	current_weakpoint = weakpoints_scene.instantiate()

	var arena_rect = Rect2(Vector2(150, 150), Vector2(1620, 780))
	current_weakpoint.position = arena_rect.position + Vector2(
		randf() * arena_rect.size.x,
		randf() * arena_rect.size.y
	)
	
	current_weakpoint.connect("tree_exited", Callable(self, "_on_weakpoint_destroyed"))
	get_parent().add_child(current_weakpoint)

func _on_weakpoint_destroyed():
	current_weakpoint = null
	if Global.weakpoints_broken <= 2 and self:
		$weakpoints_spawns.start()


func _on_vulnerable_timer_timeout():
	Global.weakpoints_broken = 0
	can_attack = true
	can_teleport = true
	is_vulnerable = false
	current_weakpoint = null
	$weakpoints_spawns.start()


func _on_starting_timer_timeout() -> void:
	can_attack = true
	
func player_firerate():
	if player != null and player.active_boosts.has("firerate"):
		$take_damage_cooldown.wait_time = 0.3
	else:
		$take_damage_cooldown.wait_time = 0.5


func low_health():
	if health < 150:
		dist_before_teleporting = 950
		$attack_cooldown.wait_time = 0.75
		$vulnerable_timer.wait_time = 3
		animated_sprite.speed_scale = 2.0
	else:
		dist_before_teleporting = 450
		$attack_cooldown.wait_time = 1
		$vulnerable_timer.wait_time = 4
