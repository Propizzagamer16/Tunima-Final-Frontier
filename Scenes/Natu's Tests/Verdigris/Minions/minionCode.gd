extends CharacterBody2D

@export var speed: float = 150.0
@export var health: int = 40
@onready var player: Node2D = null
@onready var anim = $AnimatedSprite2D

var player_in_range = false
var player_alive = true
var attack_process_running = false

func _ready():
	add_to_group("enemies")
	player = get_tree().get_nodes_in_group("player")[0]
	player.connect("player_died", Callable(self, "_on_player_died"))

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return
	
	if not player_alive:
		velocity = Vector2.ZERO
		return

	var direction = (player.global_position - global_position).normalized()
	anim.flip_h = direction.x > 0
	velocity = direction * speed
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if not attack_process_running:
			attack_process_running = true
			_attack_sequence()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		attack_process_running = false


func _attack_sequence():
	await get_tree().create_timer(0.5).timeout

	if not player_in_range or not player_alive:
		attack_process_running = false
		return

	attack_player()

	while player_in_range and player_alive:
		await get_tree().create_timer(1.0).timeout
		if player_in_range:
			attack_player()
		else:
			return

	attack_process_running = false

func attack_player():
	if player and player.has_method("take_ten_damage"):
		player.call("take_ten_damage")

func update_color():
	var health_ratio = clamp(float(health) / 40.0, 0.0, 1.0)
	var red = 1.0
	var green = health_ratio
	var blue = health_ratio
	anim.modulate = Color(red, green, blue)

func take_damage(amount):
	health -= amount
	update_color()
	if health <= 0:
		die()

func die():
	queue_free()
	MinionTracker.report_minion_killed()

func _on_player_died():
	player_alive = false
	queue_free()
