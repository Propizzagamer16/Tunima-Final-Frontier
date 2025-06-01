extends GameItem
class_name FireRate

@export var stat_to_boost: String = "firerate"
@export var boost_amount: float = 0.3
@export var duration: float = 4.0
@export var cooldown : float = 10

func use(player):
	if player.powerup_cooldowns["firerate"] > 0:
		return false
	
	if player.has_method("apply_power_up"):
		player.apply_power_up(stat_to_boost, boost_amount, duration, cooldown) 
		return true
