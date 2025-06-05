extends Area2D

@onready var player = preload("res://Scenes/Natu's Tests/Players/MainPLAYER.tscn")
var permanently_opened = false

func _ready():
	$AnimatedSprite2D.play("closed")
	$ChestUi.hide()
	
func _process(delta: float) -> void:
	if self.overlaps_body(player) and Input.is_action_just_pressed("use"):
		if not permanently_opened:
			$AnimatedSprite2D.play("opening")
			await $AnimatedSprite2D
			$AnimatedSprite2D.play("opened")
			permanently_opened = true
		$ChestUi.show()
		
