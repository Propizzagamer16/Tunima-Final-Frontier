extends Panel

@export var item : GameItem = null:
	set(value):
		item = value
		if value == null:
			$Icon.texture = null
			$Amount.text = ""
			$CooldownOverlay.visible = false
			return
		$Icon.texture = value.icon

@export var amount : int = 0:
	set(value):
		amount = value
		$Amount.text = str(value)
		if amount <= 0:
			item = null
			$CooldownOverlay.visible = false

var powerup_time := 0.0
var powerup_duration := 0.0

var cooldown_time := 0.0
var cooldown_duration := 0.0


func _process(delta):
	if powerup_time > 0:
		powerup_time -= delta
		$CooldownOverlay.visible = true
		$CooldownOverlay.anchor_top = 0.0
		$CooldownOverlay.anchor_bottom = 1.0

		if powerup_time <= 0:
			cooldown_time = cooldown_duration

	elif cooldown_time > 0:
		cooldown_time -= delta
		var ratio = clamp(cooldown_time / cooldown_duration, 0.0, 1.0)
		$CooldownOverlay.visible = true
		$CooldownOverlay.anchor_top = 1.0 - ratio
		$CooldownOverlay.anchor_bottom = 1.0

	else:
		$CooldownOverlay.visible = false


func set_amount(value: int):
	amount = value
	$Amount.text = str(value)
	if amount <= 0:
		item = null

func add_amount(value:int):
	amount += value

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if "item" in data:
		return is_instance_of(data.item, GameItem)
	return false
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var temp = item
	item = data.item
	data.item = temp
	
	temp = amount
	amount = data.amount
	data.amount = temp
	
func _get_drag_data(at_position: Vector2) -> Variant:
	return self
