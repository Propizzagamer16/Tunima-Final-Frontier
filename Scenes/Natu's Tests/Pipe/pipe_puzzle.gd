extends Node2D

@export var tile_scene: PackedScene
@export var grid_size := Vector2i(5, 4)

var tiles = []
var start_tile: Area2D
var end_tile: Area2D

var pipe_layout = [
	["elbow", "tee", "straight", "tee", "elbow"],
	["straight", "cross", "straight", "cross", "straight"],
	["elbow", "tee", "straight", "tee", "elbow"],
	["end", "straight", "elbow", "tee", "end"]
]


func _ready():
	for y in grid_size.y:
		for x in grid_size.x:
			var tile = tile_scene.instantiate()

			# Position the tile
			tile.position = Vector2(x * 240, y * 238)

			# Set the animation BEFORE _ready() is called in the tile
			var type_name = pipe_layout[y][x]
			#tile.$AnimatedSprite2D.animation = type_name

			add_child(tile)
			tiles.append(tile)

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


func get_neighbor(tile, direction: String) -> Area2D:
	# You’ll need a way to map tile positions
	# Can be done with a dictionary storing tile by grid coords
	return null  # placeholder

func check_connections():
	var visited = {}
	var to_visit = [start_tile]

	while to_visit.size() > 0:
		var current = to_visit.pop_front()
		visited[current] = true

		for direction in get_open_sides(current):
			var neighbor = get_neighbor(current, direction)
			if neighbor and opposite_side(direction) in get_open_sides(neighbor) and neighbor not in visited:
				to_visit.append(neighbor)

	return end_tile in visited
