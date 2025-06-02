extends Node2D
@export var force = -500

func _process(_delta):
	if $Area2D.overlaps_body($"../../player"):
		JumpPadGlobal.jumpOverlaped()
		print("hi")
