extends Node2D

func _process(_delta):
	if $Area2D.overlaps_body($"../../player"):
		JumpPadGlobal.jumpOverlaped()
