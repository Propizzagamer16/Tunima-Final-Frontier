extends Node2D

@onready var SceneTransitionAnimation = $scene_transition_ani/AnimationPlayer
@onready var player = get_node("player")
@onready var player_spawn_point = $player_spawnpoint

@export var enemy_scene: PackedScene
@export var strong_enemy_scene: PackedScene
@onready var progression_area := $progression_area
var player_inside_progression_area := false
@onready var enemy_spawn_points = [
	$StrongEnemySpawnPoint,
	$EnemySpawnPoint1,
	$EnemySpawnPoint2,
	$EnemySpawnPoint3
]

# Wave control variables
var current_wave : int = 0
var wave_spawn_ended := false
var wave_active := false
var strong_enemy_spawned := false
var finished_fight_played := false
var wave_spawning := false
var allow_wave_progression := true
var low_health_played := false  
var low_health_active := false
# Reset control variables
var _is_resetting := false
var _death_processed := false

func _ready():
	player.set_camera("weapons_lab")
	Global.player_type = "Side"
	player.set_mode_from_global()
	_safe_connect_player_signal()
	Global.current_wave = current_wave
	start_next_wave()

func _process(delta):
	if _is_resetting or not allow_wave_progression:
		return
		
	if wave_spawning:
		return

	if player.health <= 20 and not low_health_active:
		SceneTransitionAnimation.play("low_health")
	elif player.health > 20 and low_health_active:
		low_health_active = false
		SceneTransitionAnimation.stop()
		
	if wave_active and get_enemy_count() == 0:
		wave_active = false
		wave_spawn_ended = false

		if current_wave == 4:
			if not finished_fight_played:
				finished_fight_played = true
				SceneTransitionAnimation.play("finished_fight")
				await get_tree().create_timer(2).timeout
				progression_area.visible = true
				progression_area.monitoring = true
				progression_area.set_deferred("collision_layer", 1)
		else:
			start_next_wave()
			
	if $progression_area.overlaps_body($"player") and Input.is_action_pressed("use"):
		player.get_node("Inventory").save_inventory_state()
		get_tree().change_scene_to_file("res://Scenes/Natu's Tests/Pipe/pipe_puzzle.tscn")

func _safe_connect_player_signal():
	# Disconnect first to prevent duplicates
	if player.is_connected("player_died", _on_player_died):
		player.disconnect("player_died", _on_player_died)
	# Connect fresh
	player.connect("player_died", _on_player_died)

func get_enemy_count() -> int:
	var count = 0
	for child in get_children():
		if child.is_in_group("enemy"):
			count += 1
	return count
	
func _input(event):
	if event.is_action_pressed("change_scene_key"):
		get_tree().change_scene_to_file("res://Scenes/Natu's Tests/Pipe/pipe_puzzle.tscn")
		
		
func start_next_wave():
	if wave_spawn_ended or current_wave >= 4 or wave_spawning or _is_resetting:
		return
	wave_spawning = true
	SceneTransitionAnimation.play("scene_transition")
	Global.moving_to_next_wave = true

	current_wave += 1
	Global.current_wave = current_wave

	await get_tree().create_timer(4).timeout
	if _is_resetting:  # Don't proceed if reset happened during wait
		return
		
	await spawn_wave(current_wave)

	wave_spawn_ended = true
	wave_active = true
	wave_spawning = false

func spawn_wave(wave_number: int):
	var multiplier = 2.0
	var mobs_per_batch = 3
	var total_mobs = int(wave_number * multiplier)
	var wait_time = 2.0
	var spawn_rounds = int(ceil(float(total_mobs) / mobs_per_batch))

	await spawn_enemies(spawn_rounds, mobs_per_batch, wait_time)

func spawn_enemies(spawn_rounds: int, mobs_per_batch: int, wait_time: float):
	for i in spawn_rounds:
		if _is_resetting:
			return
		for j in mobs_per_batch:
			var spawn_index = j % enemy_spawn_points.size()
			var enemy = enemy_scene.instantiate()
			enemy.global_position = enemy_spawn_points[spawn_index + 1].global_position
			enemy.add_to_group("enemy")
			add_child(enemy)
		await get_tree().create_timer(wait_time).timeout


func _on_player_died():
	if _is_resetting or _death_processed:
		return
	
	_death_processed = true
	_is_resetting = true
	print("Player died - starting reset")
	
	await get_tree().create_timer(2.0).timeout
	await reset_level()
	
	_is_resetting = false
	_death_processed = false

func reset_level():
	print("Full level reset in progress")
	
	# Disconnect signal during reset
	if player.is_connected("player_died", _on_player_died):
		player.disconnect("player_died", _on_player_died)
	
	# Reset wave state
	low_health_played = false
	current_wave = 0
	wave_spawn_ended = false
	wave_active = false
	strong_enemy_spawned = false
	finished_fight_played = false
	Global.current_wave = current_wave
	wave_spawning = false
	allow_wave_progression = false

	# Clear all enemies
	for child in get_children():
		if child.is_in_group("enemy"):
			child.queue_free()

	# Reset player
	player.reset(player_spawn_point.global_position)
	await get_tree().create_timer(0.5).timeout

	# Reconnect signal and restart waves
	_safe_connect_player_signal()
	allow_wave_progression = true
	_is_resetting = false
	start_next_wave()

#func _input(event):
	#if event.is_action_pressed("change_scene_key") and player_inside_progression_area:
		#get_tree().change_scene_to_file("verd")
