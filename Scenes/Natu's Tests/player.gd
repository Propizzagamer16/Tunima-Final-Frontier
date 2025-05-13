extends CharacterBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var alive = true

#
func _ready():
	get_node("AnimatedSprite2D").play("Idle")

###4D MOVEMENT
@export var movement_speed: float = 500
var character_direction := Vector2.ZERO

func _physics_process(delta):
	if health <= 0:
		alive = false
		health = 0
		print("player has been killed")
		
	move_and_slide()
	player_movement(delta)
			
func player_movement(delta):	
	character_direction.x = Input.get_axis("ui_A", "ui_D")
	character_direction.y = Input.get_axis("ui_W", "ui_S")

	if character_direction != Vector2.ZERO:
		character_direction = character_direction.normalized()
		velocity = character_direction * movement_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		_ready()




##ATTACK
func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attacks(delta):
	if enemy_inattack_range and enemy_attack_cooldown:
		health -= 20
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		


func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true
