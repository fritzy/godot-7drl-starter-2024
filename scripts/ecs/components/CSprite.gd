extends Component
class_name CSprite

@export var tile_position: Vector2
@export var sheet_offset: Vector2i
@export var tile_set: TileSet
@export var position: Vector2

# unsaved
var _loaded_sprite: Sprite2D

func _postload() -> void:
	super() # setup the parent
	_loaded_sprite = Sprite2D.new()
	_loaded_sprite.texture = tile_set.get_source(0).texture
	_loaded_sprite.position = position
	_loaded_sprite.scale = Vector2(2,2)
	_loaded_sprite.region_enabled = true
	_loaded_sprite.region_rect.position = Vector2(sheet_offset * tile_set.tile_size)
	_loaded_sprite.region_rect.size = tile_set.tile_size as Vector2
	parent.add_child(_loaded_sprite)
	ResourceSaver.save(self, "res://saved_sprite.tres") # saving as an example
	
 
