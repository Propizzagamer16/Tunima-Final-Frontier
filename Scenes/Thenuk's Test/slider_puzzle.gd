extends Area2D


var tiles = []
var solved = []
var mouse = false


func _ready():
	start_game()
	
func start_game():
	tiles = [$tile1, $tile2, $tile3, $tile4, $tile5, $tile6, $tile7, $tile8, $tile9 ]
	solved = tiles.duplicate()
	shuffle_tiles()
	
func shuffle_tiles():
	var previous = 99
	var previous_1 = 98
	for t in range(0,100):
		var tile = randi() % 8
		if tiles[tile] != $tile9 and tile != previous_1:
			var rows = int(tiles[tile].position.y /360)
			var cols = int(tiles[tile].position.x /360)
			check_neighbors(rows,cols)
			previous_1 = previous
			previous = tile
	
func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and mouse:
		var mouse_copy = mouse
		print(mouse.position)
		mouse = false
		var rows = int(mouse_copy.position.y/360)
		var cols = int(mouse_copy.position.x/360)
		check_neighbors(rows,cols)
		if tiles == solved:
			print("youwin")

func check_neighbors(rows,cols):
	var empty = false
	var done = false
	var pos = rows *3+cols
	while !empty and !done:
		var new_pos = tiles[pos].position
		if rows < 3:
			new_pos.y += 360
			empty = find_empty(new_pos,pos)
			new_pos.y -=360
		if rows > 0:
			new_pos.y += 360
			empty = find_empty(new_pos,pos)
			new_pos.y -=360
		if cols < 3:
			new_pos.y += 360
			empty = find_empty(new_pos,pos)
			new_pos.y -=360
		if cols > 0:
			new_pos.y += 360
			empty = find_empty(new_pos,pos)
			new_pos.y -=360
			
func find_empty(position,pos):
	var new_rows = int(position.y /360)
	var new_cols = int(position.x /360)
	var new_pos = new_rows * 3 + new_cols

	if tiles[new_pos] == $tile9:
		swap_tiles(pos, new_pos)
		return true
	else:
		return false
		
func swap_tiles(tile_src,tile_dst):
	var temp_pos = tiles[tile_src].position
	tiles[tile_src].position = tiles[tile_dst].position
	tiles[tile_dst].position = temp_pos
	var temp_tile = tiles[tile_src]
	tiles[tile_src] = tiles[tile_dst]
	tiles[tile_dst] = temp_tile

func _input_event( viewport, event, shape_idx):
	if event is InputEventMouseButton:
		mouse = event
		
