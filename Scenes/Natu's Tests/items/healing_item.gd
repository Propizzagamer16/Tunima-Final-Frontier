extends GameItem
class_name HealingItem

@export var stat_to_boost: String = "health"
@export var boost_amount: float = 20
@export var duration: float = 0
@export var cooldown : float = 5

func use(player):
	if player.powerup_cooldowns["health"] > 0:
		return false
	
	if player.has_method("apply_power_up"):
		player.apply_power_up(stat_to_boost, boost_amount, duration, cooldown) 
		return true
