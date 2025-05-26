extends Node2D

@onready var SceneTransitionAnimation = $scene_transition_ani/AnimationPlayer
@export var tile_scene: PackedScene
@export var grid_size := Vector2i(8, 5)

var tiles = []
var nodes = []
var start_tile: Area2D
var end_tile: Area2D

var pipe_layout = [
	["start",   "elbow",    "tee",     "elbow",   "tee",     "elbow",   "tee",     "elbow"],
	["elbow",   "tee",      "node",    "tee",     "straight","tee",     "elbow",   "straight"],
	["straight","elbow",    "tee",     "elbow",   "tee",     "elbow",   "straight","tee"],
	["tee",     "straight", "elbow",   "tee",     "elbow",   "tee",     "elbow",   "tee"],
	["elbow",   "node",     "straight","tee",     "straight","tee",     "straight","end"]
]

func _ready():
	tiles.resize(grid_size.y) 
	for y in grid_size.y:
		tiles[y] = []
		for x in grid_size.x:
			var tile = tile_scene.instantiate()
			tile.position = Vector2(x * 200, y * 200)

			var type_name = pipe_layout[y][x]
			tile.get_node("AnimatedSprite2D").animation = type_name

			add_child(tile)
			tiles[y].append(tile) 

			if type_name == "node":
				nodes.append(tile)

			if x == 0 and y == 0:
				start_tile = tile
			elif x == grid_size.x - 1 and y == grid_size.y - 1:
				end_tile = tile




func get_open_sides(tile):
	return tile.get_open_sides()

func opposite_side(side: String) -> String:
	match side:
		"up":
			return "down"
		"down":
			return "up"
		"left":
			return "right"
		"right":
			return "left"
		_:
			return ""


func get_neighbor(tile: Area2D, direction: String) -> Area2D:
	var directions = {
		"up": Vector2i(0, -1),
		"down": Vector2i(0, 1),
		"left": Vector2i(-1, 0),
		"right": Vector2i(1, 0)
	}
	
	for y in grid_size.y:
		for x in grid_size.x:
			if tiles[y][x] == tile:
				var offset = directions.get(direction, Vector2i.ZERO)
				var nx = x + offset.x
				var ny = y + offset.y
				if nx >= 0 and ny >= 0 and nx < grid_size.x and ny < grid_size.y:
					return tiles[ny][nx]
				else:
					return null
	return null


func check_connections() -> bool:
	for row in tiles:
		for tile in row:
			tile.set_connected(false)

	var visited = {}
	var to_visit = [start_tile]

	while to_visit.size() > 0:
		var current = to_visit.pop_front()
		visited[current] = true
		current.set_connected(true)

		for direction in get_open_sides(current):
			var neighbor = get_neighbor(current, direction)
			if neighbor and opposite_side(direction) in get_open_sides(neighbor) and neighbor not in visited:
				to_visit.append(neighbor)

	# Check if end_tile is reachable and all nodes are visited
	var all_nodes_visited = true
	for node in nodes:
		if node not in visited:
			all_nodes_visited = false
			break

	return end_tile in visited and all_nodes_visited



func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if check_connections():
			print("Puzzle Complete")
			SceneTransitionAnimation.play("finished_fight")
			for row in tiles:
				for tile in row:
					tile.finished = true
		else:
			print("Path is not valid")
