extends Component
class_name CMap

@export var width: int = 32
@export var height: int = 32
@export var tiles: Array = []

func _postload(world: World) -> void:
	super(world)
	tiles.resize(width * height)
	
func get_tile(x: int, y: int) -> int:
	return tiles[x + y * width] as int

func set_tile(x: int, y: int, in_entity: Entity) -> void:
	clear_tile(x, y)
	tiles[x + y * width] = in_entity.id

func clear_tile(x: int, y: int) -> void:
	var tile_id := get_tile(x, y) as String
	if tile_id != null:
		var tile_entity := self.entity.level.world.get_entity(tile_id)
		tile_entity.destroy()
	tiles[x + y * width] = null

func remove() -> void:
	super()
	for tile_id: String in tiles:
		var tile_entity := self.entity.level.world.get_entity(tile_id)
		tile_entity.destroy()
	tiles.clear()
	tiles.resize(width * height)
