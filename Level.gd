extends Node2D

func _ready() -> void:
	print("instance id", get_instance_id())
	make_square_room(Rect2i(0, 0, 10, 10))
	
func make_square_room(rect: Rect2i) -> void:
	for x in range(rect.position.x, rect.end.x + 1):
		for y in range(rect.position.y, rect.end.y + 1):
			if x == rect.position.x or x == rect.end.x\
			or y == rect.position.y or y == rect.end.y:
				make_tile(Vector2i(x, y), Vector2i(0, 13))
			else:
				make_tile(Vector2i(x, y), Vector2i(3, 0))

func make_tile(position: Vector2i, tile_offset: Vector2i):
	var entity := Entity.new()
	var tile: CTile = CTile.new()
	tile.position = position
	tile.sheet_offset = tile_offset

	add_child(entity)
	entity.add_component(tile)
	return tile
