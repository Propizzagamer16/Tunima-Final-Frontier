extends Node2D

@onready var player = get_node("player")
@onready var boss = get_node("Boss_2")

func _ready():
	_safe_connect_player_signal()

func _safe_connect_player_signal():
	# Disconnect first to prevent duplicates
	if player.is_connected("player_died", _on_player_died):
		player.disconnect("player_died", _on_player_died)
	# Connect fresh
	player.connect("player_died", _on_player_died)
	
func _on_player_died():
	boss.health = 500
	Global.weakpoints_broken = 0
	player.reset($player_spawnpoint.global_position)
	await get_tree().create_timer(0.5).timeout
	_safe_connect_player_signal()
