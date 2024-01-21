extends Node
# auto_loaded as Events

signal component_added(component: Component, entity: Entity)
signal component_removed(component: Component, entity: Entity)
signal turn_start
signal turn_end

var entities_by_component: Dictionary = {}

func _ready() -> void:
	print("World...")
	
func add_component(component: Component, entity: Entity) -> void:
	if !entities_by_component.has(component.classname):
		var entities: Array[Entity] = []
		entities_by_component[component.classname] = entities
	entities_by_component[component.classname].append(entity)
	emit_signal("component_added", component, entity)

func remove_component(component: Component, entity: Entity) -> void:
	if entities_by_component.has(component.classname):
		entities_by_component[component.classname].erase(entity)
	emit_signal("component_removed", component, entity)

func register_component(component_name: String) -> void:
	var entities: Array[Entity] = []
	entities_by_component[component_name] = entities

func query(components: Array[String]) -> Array[Entity]:
	var results: Array[Entity] = []
	components.sort_custom(func(a: String, b: String) -> bool:
		return entities_by_component[a].size < entities_by_component[b].size
	)
	return results
