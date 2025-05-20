extends Node2D

@export var tile_scene: PackedScene
@export var grid_size := Vector2i(5, 5)

var tile_nodes = []

func _ready():
	for y in grid_size.y:
		for x in grid_size.x:
			var tile = tile_scene.instantiate()
			tile.position = Vector2(x * 64, y * 64)  # 64 = tile size
			add_child(tile)
			tile_nodes.append(tile)
