extends Node2D

func _process(_delta):
	if $"tele".overlaps_body($"player") and Input.is_action_pressed("use"):
		get_tree().change_scene_to_file("res://Scenes/platformer_level.tscn")
