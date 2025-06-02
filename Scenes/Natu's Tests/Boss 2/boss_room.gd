extends Node2D

@onready var player = get_node("player")
@onready var boss = get_node("Boss_2")
var SceneTransitionAnimation

func _ready():
	Global.player_type = "Top Down"
	player.set_mode_from_global()
	_safe_connect_player_signal()
	SceneTransitionAnimation = get_node("scene_transition_ani/AnimationPlayer")


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
