# Credit Jeff Lait, Brianna Stafford
# Preserve above Credit because Jeff Lait's POWDER is CC Sampling+ 1.0
# https://creativecommons.org/licenses/sampling+/1.0/
# Ported to GdScript by Nathan Fritz
# Kept isolated from game code for use in other projects.
# Made slightly more idiomatic for gdscript

extends Object
class_name GeneratorMap

var tiles: Array[int]
var width: int
var height: int
var level: int

# POWDER map dimensions
func _init(w: int = 32, h: int = 32, l: int = 0) -> void:
	level = l
	width = w
	height = h
	tiles = []
	tiles.resize(width * height)
	clear()

func clear() -> void:
	for idx: int in range(tiles.size()):
		tiles[idx] = 0

func compare_tile(x: int, y: int, tile: int) -> bool:
	return (get_tile(x, y) == tile)

func is_map_wall(x: int, y: int) -> bool:
	if x < 0 or x >= width - 1:
		return true
	if y < 0 or y >= height - 1:
		return true
	if get_tile(x, y) == GeneratorTiles.roomWall.tile_id:
		return true
	return false

func set_tile(x: int, y: int, t: int) -> void:
	var off: int = y * width + x
	if 0 <= off and off < tiles.size():
		tiles[off] = t

func get_tile(x: int, y: int) -> int:
	var off: int = y * width + x
	if 0 <= off and off < tiles.size():
		return tiles[off]
	return 0
