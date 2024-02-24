extends Node2D

var last_window_size: Vector2i
var target_ratio := 16.0/9.0
@onready var window: Window = get_tree().get_root().get_window()
var screen_size := DisplayServer.screen_get_size()
var project_window_size: Vector2i

@onready var alerts = %Alerts

@export var MainMenuScene: PackedScene
@export var ConsoleScene: PackedScene
@export var SettingsScene: PackedScene
@export var PauseScene: PackedScene
#@export var BlurMaterial: Material

var console: Console

func _ready() -> void:
	project_window_size = Vector2i(ProjectSettings.get("display/window/size/viewport_width") as int, ProjectSettings.get("display/window/size/viewport_height") as int)
	last_window_size = window.size
	Engine.max_fps = DisplayServer.screen_get_refresh_rate() as int
	print ("OS: %s" % [OS.get_name()])
	if OS.get_name() != "Web":
		load_window_settings()
	console = ConsoleScene.instantiate()
	add_child(console)
	PanelManager.add_scene_prepack(&"MainMenu", MainMenuScene, %LayerMenu)
	PanelManager.add_scene_prepack(&"Settings", SettingsScene, %LayerMenu)
	PanelManager.add_scene_prepack(&"PauseMenu", PauseScene, %LayerMenu)
	PanelManager.show_scene(&"MainMenu")
	%Level.set_process_unhandled_input(false)

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
	PanelManager.hide_scene(&"MainMenu")
	$Level.reset()
	%Level.set_process_unhandled_input(true)
	
func start_settings() -> void:
	self.console.log("open settings")

func start_load_game() -> void:
	self.console.log("load game")
	$Level.load()

func quit() -> void:
	if OS.get_name() != "Web":
		save_window_settings() 
		get_tree().quit() # default behavior
	
func save() -> void:
	$Level.save()

func pause() -> void:
	%Level.set_process_unhandled_input(false)

func resume() -> void:
	%Level.set_process_unhandled_input(true)

func resize(sizeArg: String = "") -> Array:
	var newSize: Vector2i = project_window_size
	var win_scale: float = 1
	if sizeArg != "":
		var sizes := sizeArg.split("x")
		if (sizes.size() == 1):
			win_scale = sizes[0] as float
			newSize = project_window_size * win_scale
		elif (sizes.size() == 2):
			newSize = Vector2i(max(int(sizes[0]), project_window_size.x), max(int(sizes[1]), project_window_size.y))
		else:
			newSize = Vector2i(project_window_size)
	window.size = newSize
	return [newSize, win_scale]
