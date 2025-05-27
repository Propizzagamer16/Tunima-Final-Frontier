extends CharacterBody2D

@onready var player = get_parent().find_child("player")
@onready var animated_sprite = $AnimatedSprite2D
@onready var progress_bar = $CanvasLayer/ProgressBar
@export var projectile_scene: PackedScene
@export var weakpoints_scene: PackedScene

var direction : Vector2
var player_inattack_zone = false
var can_take_damage = true
var can_attack = true
var can_teleport = true

var health: = 500:
	set(value):
		health = value
		progress_bar.value = value
		if value <= 0:
			progress_bar.visible = false
			self.queue_free()

func _ready():
	set_physics_process(false)
	Global.nodes_broken = 0

func _process(_delta):
	deal_with_damage()
	direction = player.position - position

	if direction.x < 0:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

	var dist = position.distance_to(player.position)
	
	if dist < 400:
		if can_teleport:
			teleport_away()
	else:
		attack_player()


func _physics_process(delta: float) -> void:
	velocity = direction.normalized() * 40
	move_and_collide(velocity * delta)
	
func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			health = health - 20
			$take_damage_cooldown.start()
			can_take_damage = false
	

func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
		
func teleport_away():
	var offset = (position - player.position).normalized() * 900
	global_position += offset
	
	## Optional FX or cooldown
	#$TeleportCooldown.start()
	#set_physics_process(false)  # Optional if you want to "pause" briefly

func shoot_projectile_at_player():
	var bullet = projectile_scene.instantiate()
	var shoot_dir = (player.position - position).normalized()
	var spawn_offset = shoot_dir * 350 
	bullet.global_position = global_position + spawn_offset
	bullet.direction = shoot_dir
	get_parent().add_child(bullet)


func attack_player():
	if can_attack:
		can_attack = false
		shoot_projectile_at_player()
		$attack_cooldown.start()

func _on_attack_cooldown_timeout():
	can_attack = true


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inattack_zone = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_inattack_zone = false


func _on_teleport_cooldown_timeout() -> void:
	can_teleport = true
	Global.weakpoints_broken = 0

func _on_weakpoints_spawns_timeout() -> void:
	var weakpoint = weakpoints_scene.instantiate()
	weakpoint.position = ...
