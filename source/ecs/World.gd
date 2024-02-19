extends Node2D
class_name World
# auto_loaded as Events

signal component_added(component: Component, entity: Entity)
signal component_removed(component: Component, entity: Entity)
signal turn_start
signal turn_end

var entities_by_component: Dictionary = {}
var entities_by_id: Dictionary = {}
@onready var level := get_parent()
var next_id: int = 0;

func _ready() -> void:
	print("World...")
	
func add_component(component: Component, entity: Entity) -> void:
	print("noooo")
	if !entities_by_component.has(component.classname):
		var entities: Array[Entity] = []
		entities_by_component[component.classname] = entities
	entities_by_component[component.classname].append(entity)
	emit_signal("component_added", component, entity)

func remove_component(component: Component, entity: Entity) -> void:
	if entities_by_component.has(component.classname):
		entities_by_component[component.classname].erase(entity)
	emit_signal("component_removed", component, entity)

func query(components: Array[String]) -> Array[Entity]:
	var results: Array[Entity] = []
	components.sort_custom(func(a: String, b: String) -> bool:
		return entities_by_component[a].size < entities_by_component[b].size
	)
	return results

func get_free_id() -> String:
	next_id += 1
	while entities_by_id.has("%d" % next_id):
		next_id += 1
	return "%d" % next_id

func get_entity(id: String = "") -> Entity:
	var entity: Entity
	if id == "":
		id = get_free_id()
		entity = Entity.new(id)
		entities_by_id[entity.id] = entity
		level.add_child(entity)
	elif !entities_by_id.has(id):
		entity = Entity.new(id)
		entities_by_id[id] = entity
		level.add_child(entity)
	else:
		entity = entities_by_id[id]
	return entity

func new_entity(components: Array[Component]) -> Entity:
	var entity := get_entity()
	for component: Component in components:
		entity.add_component(component)
	return entity

func clear() -> void:
	for entity: Entity in entities_by_id.values():
		entity.remove()
	entities_by_id.clear()

func _unindex_entity(entity: Entity) -> void:
	entities_by_id.erase(entity.id)

func save(path: String) -> void:
	var saved := SavedGame.new()
	for entity: Entity in entities_by_id.values():
		for ctype: String in entity.types:
			for component: Component in entity.types[ctype]:
				if component.saveable:
					saved.components.append(component)
	ResourceSaver.save(saved, path)

func load(path: String) -> bool:
	if !ResourceLoader.exists(path):
		return false
	var saved: SavedGame = ResourceLoader.load(path)
	for comp: Component in saved.components:
		var entity := get_entity(comp.entity_id)
		entity.add_component(comp)
	return true
