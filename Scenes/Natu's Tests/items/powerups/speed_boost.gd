extends GameItem
class_name SpeedBoost

@export var stat_to_boost: String = "speed"
@export var boost_amount: float = 300
@export var duration: float = 8.0

func use(player):
	if player.has_method("apply_power_up"):
		player.apply_power_up(stat_to_boost, boost_amount, duration) 
