extends Node

@onready var player = preload("res://Scenes/Natu's Tests/Players/MainPLAYER.tscn")
var kill_count = 0
var kill_target = 15

signal kill_goal_reached

func _ready() -> void:
	_safe_connect_player_signal()
	
func _safe_connect_player_signal():
	if player.is_connected("player_died", _on_player_died):
		player.disconnect("player_died", _on_player_died)
	player.connect("player_died", _on_player_died)

func _on_player_died():
	reset()
	
func reset():
	kill_count = 0

func report_minion_killed():
	kill_count += 1
	if kill_count >= kill_target:
		emit_signal("kill_goal_reached")
