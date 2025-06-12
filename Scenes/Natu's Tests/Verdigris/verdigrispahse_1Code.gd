extends Node2D

@onready var player = get_node("player")
@onready var boss = get_node("Verdigris")

func _ready():
	player.set_camera("Verdigris Phase 1")
	Global.player_type = "Side"
	player.set_mode_from_global()
	player.JUMP_FORCE = -1500
	Global.player_type = "Side"
