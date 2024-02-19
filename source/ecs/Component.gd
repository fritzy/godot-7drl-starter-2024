extends Resource
class_name Component

@export var entity_id: String
@export var index: StringName
var entity: Entity
static var saveable: bool = true

func _init(values: Dictionary = {}) -> void:
	for key: StringName in values:
		self[key] = values[key]

func _postload(world: World) -> void:
	entity = world.get_entity(entity_id)

func _presave() -> void:
	pass

func remove() -> void:
	pass
