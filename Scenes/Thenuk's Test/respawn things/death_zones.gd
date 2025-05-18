extends Area2D

var SceneTransitionAnimation
var checkpoint_manager
var player

func _ready() -> void:
	SceneTransitionAnimation = get_parent().get_node("scene_transition_ani/AnimationPlayer")
	checkpoint_manager = get_parent().get_node("checkpoint_manager")
	player = get_parent().get_node("player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneTransitionAnimation.play("death")
		await get_tree().create_timer(1.2).timeout
		kill_player()
		
func kill_player():
	player.position = checkpoint_manager.last_location
