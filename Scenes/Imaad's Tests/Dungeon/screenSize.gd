extends Node2D

var original_size: Vector2i

func _ready():
	# Store the original window size
	original_size = DisplayServer.window_get_size()

	# Set new temporary window size
	DisplayServer.window_set_size(Vector2i(800, 450))

	# Optional: Re-center the window
	DisplayServer.window_set_position(DisplayServer.screen_get_size() / 2 - Vector2i(400, 225))


func _exit_tree():
	# Restore the original window size when the scene tree is exiting
	DisplayServer.window_set_size(original_size)
	DisplayServer.window_set_position(DisplayServer.screen_get_size() / 2 - original_size / 2)
