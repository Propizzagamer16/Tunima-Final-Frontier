extends Node

signal LeverChanged

func leverChanged():
	emit_signal("LeverChanged")
