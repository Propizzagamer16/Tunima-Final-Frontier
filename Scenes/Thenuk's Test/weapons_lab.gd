extends Node2D

@onready var SceneTransitionAnimation = $scene_transition_ani/AnimationPlayer

@export var enemy_scene: PackedScene
@export var strong_enemy_scene: PackedScene

@onready var enemy_spawn_points = [
	$StrongEnemySpawnPoint,
	$EnemySpawnPoint1,
	$EnemySpawnPoint2,
	$EnemySpawnPoint3
]

var current_wave : int = 0
var wave_spawn_ended := false
var wave_active := false
var strong_enemy_spawned := false
var finished_fight_played := false

func _ready():
	Global.current_wave = current_wave
	start_next_wave()


func _process(delta):
	if wave_active and get_enemy_count() == 0:
		wave_active = false
		wave_spawn_ended = false

		# Special handling for wave 4
		if current_wave == 4:
			if not strong_enemy_spawned:
				strong_enemy_spawned = true
				spawn_strong_enemy()
				wave_active = true  # resume tracking for the boss
			elif not finished_fight_played:
				finished_fight_played = true
				await get_tree().create_timer(2).timeout
				SceneTransitionAnimation.play("finished_fight")
		else:
			start_next_wave()


func get_enemy_count() -> int:
	var count = 0
	for child in get_children():
		if child.is_in_group("enemy"):
			count += 1
	return count


func start_next_wave():
	if wave_spawn_ended or current_wave >= 4:
		return

	SceneTransitionAnimation.play("scene_transition")
	Global.moving_to_next_wave = true

	current_wave += 1
	Global.current_wave = current_wave

	await get_tree().create_timer(4).timeout
	spawn_wave(current_wave)
	wave_spawn_ended = true
	wave_active = true


func spawn_wave(wave_number: int):
	var multiplier = 2.0
	var mobs_per_batch = 3
	var total_mobs = int(wave_number * multiplier)
	var wait_time = 2.0
	var spawn_rounds = int(ceil(float(total_mobs) / mobs_per_batch))

	await spawn_enemies(spawn_rounds, mobs_per_batch, wait_time)


func spawn_enemies(spawn_rounds: int, mobs_per_batch: int, wait_time: float):
	for i in spawn_rounds:
		for j in mobs_per_batch:
			var spawn_index = j % enemy_spawn_points.size()
			var enemy = enemy_scene.instantiate()
			enemy.global_position = enemy_spawn_points[spawn_index + 1].global_position
			enemy.add_to_group("enemy")
			add_child(enemy)
		await get_tree().create_timer(wait_time).timeout


func spawn_strong_enemy():
	var strong_enemy = strong_enemy_scene.instantiate()
	strong_enemy.global_position = enemy_spawn_points[0].global_position
	strong_enemy.add_to_group("enemy")
	add_child(strong_enemy)
