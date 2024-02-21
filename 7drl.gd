extends Node2D

var last_window_size: Vector2i
var target_ratio := 16.0/9.0
@onready var window: Window = get_tree().get_root().get_window()
var screen_size := DisplayServer.screen_get_size()
var project_window_size: Vector2i

@export var MainMenuScene: PackedScene
@export var ConsoleScene: PackedScene
var console: Console

func _ready() -> void:
	project_window_size = Vector2i(ProjectSettings.get("display/window/size/viewport_width") as int, ProjectSettings.get("display/window/size/viewport_height") as int)
	last_window_size = window.size
	Engine.max_fps = DisplayServer.screen_get_refresh_rate()
	print ("OS: %s" % [OS.get_name()])
	if OS.get_name() != "Web":
		load_window_settings()
	var current_scene := MainMenuScene.instantiate()
	#var menu := current_scene.get_node("MainMenu")
	self.position.y = -1080.0
	get_tree().create_tween()\
		.tween_property(self, "position", Vector2(0, 0), 0.5)\
		.set_trans(Tween.TRANS_SINE)
	add_child(current_scene)
	console = ConsoleScene.instantiate()
	add_child(console)

func _notification(what: int) -> void:
	# when closing
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()

func load_window_settings() -> void:
	if !ResourceLoader.exists("user://windowdata.tres"):
		return
	var ws: WindowResource = ResourceLoader.load("user://windowdata.tres")
	if ws != null:
		print("loading window data", ws.position, ws.size)
		if (ws.position.x < screen_size.x - 150
			and ws.position.y < screen_size.y - 150
			and ws.position.x > -ws.size.x + 150
			and ws.position.y > -ws.size.y + 150):
			window.position = ws.position
		else:
			window.position = Vector2i(0,0)
		if screen_size.x >= ws.size.x and screen_size.y >= ws.size.y:
			window.size = ws.size
		else:
			window.size = screen_size
		DisplayServer.window_set_mode(ws.window_mode) # restore fullscreen

func save_window_settings() -> void:
	var ws: = WindowResource.new()
	ws.position = window.position
	ws.size = window.size
	ws.window_mode = DisplayServer.window_get_mode()
	ResourceSaver.save(ws, "user://windowdata.tres")

func start_new_game() -> void:
	self.console.log("new game now")
	$Level.reset()
	
func start_options() -> void:
	self.console.log("open options")

func start_load_game() -> void:
	self.console.log("load game")
	$Level.load()

func quit() -> void:
	save_window_settings() 
	get_tree().quit() # default behavior
	
func save() -> void:
	$Level.save()
