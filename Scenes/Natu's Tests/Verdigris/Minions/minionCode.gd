extends CharacterBody2D

@export var speed: float = 150.0
@export var health: int = 40
@onready var player: Node2D = null
@onready var anim = $AnimatedSprite2D
@onready var attack_timer = $attack_timer

var player_in_range = false
var player_alive = true

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
		await get_tree().create_timer(0.5).timeout
		if player_in_range and player_alive:
			attack_player()
			attack_timer.start()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		attack_timer.stop()

func _on_attack_timer_timeout():
	if player_in_range and player_alive:
		attack_player()

func attack_player():
	if player.has_method("take_ten_damage"):
		player.call("take_ten_damage")

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()
	MinionTracker.report_minion_killed()

func _on_player_died():
	set_physics_process(false)
