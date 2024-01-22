extends Node
class_name Entity

@export var components: Array[Component] = []

func _ready() -> void:
	print("entity ready")
	var tile := CSprite.new()
	tile.tile_set = ResourceLoader.load("res://resources/kenney_1-bit-pack/Tilesheet/kenny_1_bit_tileset.tres")
	tile.position = Vector2(20, 20)
	tile.sheet_offset = Vector2i(0, 1)
	add_component(tile)

func add_component(component: Component) -> void:
	print("adding component")
	components.append(component)
	component.entity_id = get_instance_id()
	component._postload()
