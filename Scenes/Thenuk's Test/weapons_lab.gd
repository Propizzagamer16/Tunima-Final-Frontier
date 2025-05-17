extends Node2D

@onready var SceneTransitionAnimation = $scene_transition_ani/AnimationPlayer

@export var enemy_scene: PackedScene
@onready var enemy_spawn_points = [
	$EnemySpawnPoint1,
	$EnemySpawnPoint2,
	$EnemySpawnPoint3
]

var current_wave : int = 0
var wave_spawn_ended := false
var wave_active := false

func _ready():
	Global.current_wave = current_wave
	position_to_next_wave()


func _process(delta):
	# Check if all enemies are gone and spawn ended, then move to next wave, stop at 3 waves
	if current_wave <= 3:
		if wave_active and get_enemy_count() == 0:
			wave_active = false
			wave_spawn_ended = false
			position_to_next_wave()


func get_enemy_count() -> int:
	var count = 0
	for child in get_children():
		if child.is_in_group("enemy"):  
			count += 1
	return count


func position_to_next_wave():
	if not wave_spawn_ended:
		Global.moving_to_next_wave = true
		SceneTransitionAnimation.play("scene_transition")

		current_wave += 1
		Global.current_wave = current_wave

		await get_tree().create_timer(4).timeout
		prepare_spawn("enemy", 2.0, 3) 
		wave_spawn_ended = true
		wave_active = true


func prepare_spawn(type: String, multiplier: float, mobs_per_batch: int):
	var mob_amount = int(current_wave * multiplier)
	var mob_wait_time: float = 2.0
	var spawn_rounds = int(ceil(float(mob_amount) / mobs_per_batch))

	spawn_type(type, spawn_rounds, mobs_per_batch, mob_wait_time)


func spawn_type(type: String, spawn_rounds: int, mobs_per_batch: int, wait_time: float):
	if type != "enemy":
		return

	for i in spawn_rounds:
		for j in mobs_per_batch:
			var spawn_index = j % enemy_spawn_points.size()
			var enemy = enemy_scene.instantiate()
			enemy.global_position = enemy_spawn_points[spawn_index].global_position
			enemy.add_to_group("enemy")
			add_child(enemy)
		await get_tree().create_timer(wait_time).timeout
