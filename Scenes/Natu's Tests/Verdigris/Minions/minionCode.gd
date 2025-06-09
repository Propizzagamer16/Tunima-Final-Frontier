extends CharacterBody2D

@export var speed: float = 150.0
@export var health: int = 40
@onready var player: Node2D = null

func _ready():
	add_to_group("enemies")
	player = get_tree().get_nodes_in_group("player")[0]

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()
	MinionTracker.report_minion_killed()
