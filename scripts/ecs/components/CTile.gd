extends Component
class_name CTile

@export var position: Vector2i
@export var sheet_offset: Vector2i
@export var layer: String
@export var tile_set: TileSet

func _postload() -> void:
	super()
	var map: TileMap = parent.get_parent().get_node("%LevelTileMap")
	print ("setting tile ", position)
	map.set_cell(0, position, 0, sheet_offset)

func presave() -> void:
	pass
