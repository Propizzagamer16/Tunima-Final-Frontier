extends Node2D

@onready var player = get_node("player")
@onready var boss = get_node("Boss_2")
@onready var progression_area := $progression_area
var player_inside_progression_area := false
var SceneTransitionAnimation


func _ready():
	player.set_camera("boss_2")
	Global.player_type = "Top Down"
	player.set_mode_from_global()
	_safe_connect_player_signal()
	SceneTransitionAnimation = get_node("scene_transition_ani/AnimationPlayer")
	progression_area.visible = false

func _process(_delta):
	if $"progression_area".overlaps_body($"player") and Input.is_action_pressed("use"):
		get_tree().change_scene_to_file("res://Scenes/Thenuk's Test/Platformer/ice_path.tscn")

func _safe_connect_player_signal():
	# Disconnect first to prevent duplicates
	if player.is_connected("player_died", _on_player_died):
		player.disconnect("player_died", _on_player_died)
	player.connect("player_died", _on_player_died)
	
func _on_player_died():
	SceneTransitionAnimation.play("death")
	await get_tree().create_timer(1.2).timeout
	boss.health = 500
	Global.weakpoints_broken = 0
	player.reset($player_spawnpoint.global_position)
	boss.can_attack = false
	await get_tree().create_timer(0.5).timeout
	_safe_connect_player_signal()
	
