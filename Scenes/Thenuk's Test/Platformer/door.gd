extends Node2D
@export var code := "0"
var codeFromLevers := ""
var levers := []

func _ready():
	levers = get_node("Levers").get_children()
	LeverGobal.LeverChanged.connect(CheckCode)

	for lever in levers:
		print(lever.name, '', lever.state)

	CheckCode()  

func CheckCode():
	codeFromLevers = ""
	for lever in levers:
		codeFromLevers += str(lever.state)

	print("Code from levers:", codeFromLevers)

	if code == codeFromLevers:
		$"StaticBody2D/CollisionShape2D".disabled = false
		$Closed.visible = true  # unlock
	else:
		$"StaticBody2D/CollisionShape2D".disabled = true 
		$Closed.visible = false # lock
