extends Node2D
@onready var player = get_node("player")

func _ready():
	Global.player_type = "Side"
	player.set_mode_from_global()
	var player = get_node("player") 
	var camera = player.get_node("Camera2D")
	camera.zoom = Vector2(1,1) 
	player.set_camera("platformer")
