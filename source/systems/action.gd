extends Object
class_name ActionSystem

var world: World
var action_queue: Array
var animation_queue: Array

func _init(_world: World):
	world = _world
	world.query(ActionComponent)
	
