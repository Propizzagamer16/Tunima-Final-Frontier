extends Node2D
@onready var player = get_node("player")

func _ready():
	
	var camera = player.get_node("Camera2D")
	Global.player_type = "Side"
	player.set_mode_from_global()
	camera.zoom = Vector2(1,1) 
	player.set_camera("platformer")
	#player.JUMP_FORCE = -1100.0
	player.gravitydelta = 0.04

func _input(event):
	if event.is_action_pressed("change_scene_key"):
		player.get_node("Inventory").save_inventory_state()
		get_tree().change_scene_to_file("res://Scenes/Thenuk's Test/slider/slider_puzzle.tscn")

func _process(_delta):
	if $"tele".overlaps_body($"player") and Input.is_action_pressed("use"):
		player.get_node("Inventory").save_inventory_state()
		get_tree().change_scene_to_file("res://Scenes/Thenuk's Test/slider/slider_puzzle.tscn")
