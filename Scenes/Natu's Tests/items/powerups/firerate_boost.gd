extends GameItem
class_name FireRate

func use(player):
	if player.has_method("apply_power_up"):
		player.apply_power_up("firerate", 0.25, 5)
