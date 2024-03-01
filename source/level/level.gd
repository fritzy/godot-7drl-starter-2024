extends Node2D
class_name Level

var level_rng := RandomNumberGenerator.new()

@onready var world: World = get_node("World")
var entities_by_map: Dictionary = {
	0: {}
}

func _ready() -> void:
	generate()

func generate() -> void:
	#var width: int = randi_range(3, 20)
	#var height: int = randi_range(3, 20)
	#make_square_room(Rect2i(0, 0, width, height))
	#make_square_room(Rect2i(width + 2, 1, randi_range(3,15), randi_range(3, 15)))
	var generator := RoguelikeGenerator.new(level_rng)
	var w := 64
	var h := 36
	var r: = 30
	var map := generator.generate(w, h, r, 0, true)
	for x: int in w:
		for y: int in h:
			var tile: int = map.get_tile(x, y)
			#print ("%dx%d" % [x, y], map.get_tile(x, y))
			if tile == GeneratorTiles.roomFloor.tile_id:
				make_tile(Vector2i(x, y), Vector2i(3, 0))
			elif tile == GeneratorTiles.roomWall.tile_id:
				make_tile(Vector2i(x, y), Vector2i(6, 13))
			elif tile == GeneratorTiles.stoneWall.tile_id:
				make_tile(Vector2i(x, y), Vector2i(0, 13))
			elif tile == GeneratorTiles.stoneFloor.tile_id:
				make_tile(Vector2i(x, y), Vector2i(19, 1))
			elif tile == GeneratorTiles.door.tile_id:
				make_tile(Vector2i(x, y), Vector2i(10, 9))
			elif tile == GeneratorTiles.stairsUp.tile_id:
				make_tile(Vector2i(x, y), Vector2i(2, 6))
			elif tile == GeneratorTiles.stairsDown.tile_id:
				make_tile(Vector2i(x, y), Vector2i(3, 6))

func reset() -> void:
	world.clear()
	generate()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		PanelManager.show_scene(&"PauseMenu")
		print("level escape")
		get_viewport().set_input_as_handled()
		get_parent().pause()

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
	world.save("user://savedgame.res")

func load() -> void:
	world.clear()
	world.load("user://savedgame.res")

func _set_ctile(ctile: CTile) -> void:
	self.entities_by_map[ctile.layer]["%dx%d" % [ctile.position.x, ctile.position.y]] = ctile.entity

func _clear_ctile(ctile: CTile) ->void:
	self.entities_by_map[ctile.layer].delete("%dx%d" % [ctile.position.x, ctile.position.y])
