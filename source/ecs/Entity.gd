extends Node
class_name Entity

static var id_count: int = 0
@export var id: String = ""
@onready var level: Level = get_parent()
var index: Dictionary = {}
var types: Dictionary = {}
var tags: Dictionary = {}

func _ready() -> void:
	pass

func _init(_id: String = "") -> void:
	self.id = _id

func add_component(component: Component) -> void:
	var cname := component.get_class()
	if !types.has(cname):
		types[cname] = []
		#TODO add to world search
	types[cname].append(component)
	component.entity_id = self.id
	if component.index:
		index[component.index] = component
	component._postload(level.world)

func remove_component(component: Component) -> void:
	var cname := component.get_class()
	var cidx: int = types[cname].find(component)
	var comp = types[cname].pop_at(cidx)
	if comp.index:
		index.erase(component.index)
	comp.remove()
	if (types[cname].size() == 0):
		types.erase(cname)
		#TODO: remove from world search

func remove() -> void:
	clear_components()
	level.world._unindex_entity(self)
	queue_free()
	
func clear_components() -> void:
	for type: String in types:
		for comp in types[type]:
			remove_component(comp)
	

func has(type: String) -> bool:
	return self.types.has(type)
