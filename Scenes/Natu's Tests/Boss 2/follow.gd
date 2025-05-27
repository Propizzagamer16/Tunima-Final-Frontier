extends State
#
#
#func enter():
	#super.enter()
	#owner.set_physics_process(true)
	##ani plays idle
#
#func exit():
	#super.exit()
	#owner.set_physics_process(false)
#
#func transition():
	#if owner.direction.length() < 350:
		#get_parent().change_state("Attack")
