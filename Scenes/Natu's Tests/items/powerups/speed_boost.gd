extends GameItem
class_name SpeedBoost

@export var stat_to_boost: String = "speed"
@export var boost_amount: float = 300
@export var duration: float = 8.0
@export var cooldown : float = 15

func use(player):
	if player.powerup_cooldowns[stat_to_boost] > 0:
		return false
		
	if player.has_method("apply_power_up"):
		player.apply_power_up(stat_to_boost, boost_amount, duration, cooldown) 
		return true
