extends Node

signal jumpOverlap

func jumpOverlaped():
	emit_signal("jumpOverlap")
