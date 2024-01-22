extends Node
class_name Entity

@export var components: Array[Component] = []

func _ready() -> void:
	print("entity ready")

func add_component(component: Component) -> void:
	print("adding component")
	components.append(component)
	component.entity_id = get_instance_id()
	component._postload()
