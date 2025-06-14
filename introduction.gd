extends Node2D

@onready var player = get_node("player")

func _ready():
	# Camera changes for scene
	Global.player_type = "Top Down"
	player.set_mode_from_global()
	player.set_camera("Introduction")
	
func _input(event):
	if event.is_action_pressed("change_scene_key"):
		get_tree().change_scene_to_file("res://Scenes/Imaad's Tests/Dungeon/(S) Dungeon.tscn")
