extends CharacterBody2D

enum BossPhase { phase1, phase2, phase3 }

var phase = BossPhase.phase1
var state: String = "idle"
var health = 5000

var health_thresholds : Dictionary = {"phase2": 3500, "phase3": 1750}

#minons spawning
@export var minion_scene: PackedScene
@onready var spawn_timer: Timer = $minion_spawn_timer
@onready var spawn_positions = get_tree().current_scene.get_node("Minion Spawning").get_children()


func _ready():
	if phase == BossPhase.phase1:
		MinionTracker.reset()
		MinionTracker.kill_goal_reached.connect(_on_phase1_complete)
		spawn_timer.timeout.connect(_spawn_minion)
		spawn_timer.start()

func _process(_delta):
	if health <= health_thresholds["phase2"] and phase == BossPhase.phase1:
		change_phase(BossPhase.phase2)
	elif health <= health_thresholds["phase3"] and phase == BossPhase.phase2:
		change_phase(BossPhase.phase3)

func change_phase(new_phase: BossPhase):
	phase = new_phase
	#match phase:
		#BossPhase.phase1:
			#setup_phase_1()
		#BossPhase.phase2:
			#setup_phase_2()
		#BossPhase.phase3:
			#setup_phase_3()
			
func _spawn_minion():
	var pos = spawn_positions.pick_random()
	var minion = minion_scene.instantiate()
	get_tree().current_scene.add_child(minion)
	minion.global_position = pos.global_position

func _on_phase1_complete():
	spawn_timer.stop()
	change_phase(BossPhase.phase2)

func _on_spawn_timer_timeout():
	var pos = spawn_positions.pick_random()
	var minion = minion_scene.instantiate()
	get_tree().current_scene.add_child(minion)
	minion.global_position = pos.global_position
