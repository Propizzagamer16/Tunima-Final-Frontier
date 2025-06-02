extends Node2D

func _process(_delta):
	if $Area2D.overlaps_body($"../../player") and Input.is_action_pressed("ui_W"):
		ChainGlobal.ChainOverlaped()
