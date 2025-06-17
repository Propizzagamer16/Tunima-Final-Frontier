extends Node2D

@onready var player = get_node("player")
@onready var boss = get_node("Verdigris")
@onready var SceneTransitionAnimation =  $scene_transition_ani/AnimationPlayer

func _ready():
	player.set_camera("Verdigris Phase 1")
	Global.player_type = "Side"
	player.set_mode_from_global()
	player.JUMP_FORCE = -1500
	_safe_connect_player_signal()

func _input(event):
	if event.is_action_pressed("change_scene_key"):
		get_tree().change_scene_to_file("res://Scenes/Thenuk's Test/main menu/main_menu.tscn")

func _safe_connect_player_signal():
	if player.is_connected("player_died", _on_player_died):
		player.disconnect("player_died", _on_player_died)
	player.connect("player_died", _on_player_died)
	
func _on_player_died():
	SceneTransitionAnimation.play("death")
	await get_tree().create_timer(1.2).timeout
	player.reset($player_spawnpoint.global_position)
	await get_tree().create_timer(0.5).timeout
	_safe_connect_player_signal()
