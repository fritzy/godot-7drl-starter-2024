extends Resource
class_name Component

var entity_id: int
var parent: Entity

func _postload() -> void:
	parent = instance_from_id(entity_id)

func _presave() -> void:
	pass
