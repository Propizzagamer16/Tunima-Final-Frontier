extends State


func enter():
	super.enter()
	combo()

func attack(move = "1"):
	#ani plays attack
	#await animation
	pass
	
func combo():
	#var moveset = animation
	#for i in moveset:
	#	await attack(i)
	#combo()
	pass

func transition():
	if owner.direction.length() < 350:
		get_parent().change_state("Teleport")
