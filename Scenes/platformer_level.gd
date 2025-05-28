extends Node2D

func _ready():
	var player = get_node("player") 
	var camera = player.get_node("Camera2D")
	camera.zoom = Vector2(1,1) 
