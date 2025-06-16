extends Area2D

const TILE_SIZE = 360
const GRID_SIZE = 3
const PUZZLE_WIDTH = TILE_SIZE * GRID_SIZE
const PUZZLE_HEIGHT = TILE_SIZE * GRID_SIZE
const SCREEN_WIDTH = 1920
const SCREEN_HEIGHT = 1080
const START_X = SCREEN_WIDTH / 2 - PUZZLE_WIDTH / 2 + TILE_SIZE / 2  # 600
const START_Y = SCREEN_HEIGHT / 2 - PUZZLE_HEIGHT / 2 + TILE_SIZE / 2  # 180

var tiles = []
var solved = []

func _ready():
	tiles = [$tile1, $tile2, $tile3, $tile4, $tile5, $tile6, $tile7, $tile8, $tile9]
	solved = tiles.duplicate()

	# Position all tiles in a 3x3 grid centered on the screen
	for i in range(tiles.size()):
		var row = i / GRID_SIZE
		var col = i % GRID_SIZE
		tiles[i].position = Vector2(START_X + col * TILE_SIZE, START_Y + row * TILE_SIZE)

	shuffle_tiles()

func shuffle_tiles():
	var empty_index = 8
	for t in range(100):
		var neighbors = get_movable_neighbors(empty_index)
		var choice = neighbors[randi() % neighbors.size()]
		swap_tiles(choice, empty_index)
		empty_index = choice

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = event.position
		for i in range(tiles.size()):
			if tiles[i] == $tile9:
				continue  # Skip empty tile
			var tile = tiles[i]
			var rect = Rect2(tile.position - tile.texture.get_size() / 2, tile.texture.get_size())
			if rect.has_point(click_pos):
				var row = int((tile.position.y - START_Y + TILE_SIZE / 2) / TILE_SIZE)
				var col = int((tile.position.x - START_X + TILE_SIZE / 2) / TILE_SIZE)
				check_neighbors(row, col)
				if tiles == solved:
					get_tree().change_scene_to_file("res://Scenes/Thenuk's Test/weaponslab/weapons_lab.tscn")
				break

func check_neighbors(row, col):
	var index = row * GRID_SIZE + col
	var neighbors = get_movable_neighbors(index)
	for n in neighbors:
		if tiles[n] == $tile9:
			swap_tiles(index, n)
			break

func get_movable_neighbors(index):
	var neighbors = []
	var row = index / GRID_SIZE
	var col = index % GRID_SIZE
	if row > 0: neighbors.append(index - GRID_SIZE)
	if row < GRID_SIZE - 1: neighbors.append(index + GRID_SIZE)
	if col > 0: neighbors.append(index - 1)
	if col < GRID_SIZE - 1: neighbors.append(index + 1)
	return neighbors

func swap_tiles(i, j):
	var temp_pos = tiles[i].position
	tiles[i].position = tiles[j].position
	tiles[j].position = temp_pos
	var temp_tile = tiles[i]
	tiles[i] = tiles[j]
	tiles[j] = temp_tile
