extends GameItem
class_name HealingItem

@export var heal_amount: int = 20

func use(player):
	if player.has_method("heal"):
		player.heal(heal_amount)
