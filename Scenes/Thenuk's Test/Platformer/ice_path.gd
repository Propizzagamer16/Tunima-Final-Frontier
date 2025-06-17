extends Node2D

func _process(_delta):
	if $"tele".overlaps_body($icepathmovement):
		get_tree().change_scene_to_file("res://Scenes/Natu's Tests/Verdigris/verdigrispahse 1(GOOD).tscn")

func _input(event):
	if event.is_action_pressed("change_scene_key"):
		get_tree().change_scene_to_file("res://Scenes/Natu's Tests/Verdigris/verdigrispahse 1(GOOD).tscn")
