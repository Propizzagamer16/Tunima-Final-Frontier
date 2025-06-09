extends Node

var kill_count = 0
var kill_target = 15

signal kill_goal_reached

func reset():
	kill_count = 0

func report_minion_killed():
	kill_count += 1
	if kill_count >= kill_target:
		emit_signal("kill_goal_reached")
