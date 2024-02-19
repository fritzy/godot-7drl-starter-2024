extends Component
class_name CTile

@export var position: Vector2i
@export var sheet_offset: Vector2i
@export var layer: int
@export var tile_set: TileSet
var map: TileMap

func _postload(world: World) -> void:
	super(world)
	map = world.level.get_node("%LevelTileMap")
	map.set_cell(0, position, 0, sheet_offset)
	world.level._set_ctile(self)

func remove() -> void:
	super()
	map.erase_cell(0, position)
