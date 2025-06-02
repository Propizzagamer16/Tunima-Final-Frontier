extends Node

signal ChainOverlap

func ChainOverlaped():
	emit_signal("ChainOverlap")
