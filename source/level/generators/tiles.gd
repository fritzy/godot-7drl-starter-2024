# Credit Jeff Lait, Brianna Stafford
# Preserve above Credit because Jeff Lait's POWDER is CC Sampling+ 1.0
# https://creativecommons.org/licenses/sampling+/1.0/
# Ported to GdScript by Nathan Fritz
# Kept isolated from game code for use in other projects.
# Made slightly more idiomatic for gdscript

extends Object
class_name GeneratorTiles

static var tileset: Dictionary = {}
static var stoneWall: Tile = Tile.new(0, true)
static var stoneFloor: Tile = Tile.new(1, false)
static var roomWall: Tile = Tile.new(2, true)
static var roomFloor: Tile = Tile.new(3, false)
static var stairsUp: Tile = Tile.new(4, false)
static var stairsDown: Tile = Tile.new(5, false)
static var water: Tile = Tile.new(6, false)
static var door: Tile = Tile.new(7, true)

class Tile:
	var tile_id: int
	var is_solid: bool
	
	func _init(id: int, solid: bool) -> void:
		is_solid = solid
		tile_id = id
