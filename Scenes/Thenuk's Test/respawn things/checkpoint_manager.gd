extends Node2D

var last_location
var player

func _ready() -> void:
	player = get_parent().get_node("player")
	last_location = player.global_position
