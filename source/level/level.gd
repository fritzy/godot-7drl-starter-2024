extends Node2D
class_name Level

@onready var world: World = get_node("World")
var entities_by_map: Dictionary = {
	0: {}
}

func _ready() -> void:
	print("instance id", get_instance_id())
	generate()

func generate() -> void:
	var width: int = randi_range(3, 20)
	var height: int = randi_range(3, 20)
	make_square_room(Rect2i(0, 0, width, height))
	make_square_room(Rect2i(width + 2, 1, randi_range(3,15), randi_range(3, 15)))

func reset() -> void:
	world.clear()
	generate()

func make_square_room(rect: Rect2i) -> void:
	for x in range(rect.position.x, rect.end.x + 1):
		for y in range(rect.position.y, rect.end.y + 1):
			if x == rect.position.x or x == rect.end.x\
			or y == rect.position.y or y == rect.end.y:
				make_tile(Vector2i(x, y), Vector2i(0, 13))
			else:
				make_tile(Vector2i(x, y), Vector2i(3, 0))

func make_tile(tile_position: Vector2i, tile_offset: Vector2i) -> void:
	world.new_entity([CTile.new({
		&"position": tile_position,
		&"sheet_offset": tile_offset
	})])

func save() -> void:
	world.save()

func load() -> void:
	world.clear()
	world.load()

func _set_ctile(ctile: CTile) -> void:
	self.entities_by_map[ctile.layer]["%dx%d" % [ctile.position.x, ctile.position.y]] = ctile.entity

func _clear_ctile(ctile: CTile) ->void:
	self.entities_by_map[ctile.layer].delete("%dx%d" % [ctile.position.x, ctile.position.y])
