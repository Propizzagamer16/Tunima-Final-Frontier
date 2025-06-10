extends Node2D

func _input(event):
	if event.is_action_pressed("change_scene_key"):
		get_tree().change_scene_to_file("res://Scenes/Imaad's Tests/Dungeon/(S) Dungeon.tscn")
