extends Node2D
@onready var player = get_node("player")

func _ready():
	Global.player_type = "Side"
	player.set_mode_from_global()
	var player = get_node("player") 
	var camera = player.get_node("Camera2D")
	camera.zoom = Vector2(1,1) 
	player.set_camera("platformer")

func _input(event):
	if event.is_action_pressed("change_scene_key"):
		get_tree().change_scene_to_file("res://Scenes/Natu's Tests/Boss 2/boss_room.tscn")
