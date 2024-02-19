extends Node
class_name Entity

static var id_count: int = 0
@export var id: String = ""
@onready var level: Level = get_parent()
var index: Dictionary = {}
var types: Dictionary = {}

func _ready() -> void:
	print("entity ready")

func _init(id: String = "") -> void:
	self.id = id

func add_component(component: Component) -> void:
	print("adding component")
	var cname := component.get_class()
	if !types.has(cname):
		types[cname] = []
	types[cname].append(component)
	component.entity_id = self.id
	if component.index:
		index[component.index] = component
	component._postload(level.world)
