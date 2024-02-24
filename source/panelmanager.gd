extends Node

var scenes := {}
enum Side {TOP, BOTTOM, LEFT, RIGHT}
enum Transition {NONE, SLIDE}

var scene_info := {}
var last_active: Array[StringName] = []
var default_cancel: StringName

func _ready() -> void:
	default_cancel = &"PauseMenu"
	
func add_scene_instance(scene_name: StringName, instance: Node2D, layer: Node2D) -> void:
	if scenes.has(scene_name):
		push_error("Scene Already Exists %s" % name)
		return
	_setup_scene(scene_name, instance, layer)

func _setup_scene(scene_name: StringName, scene: Variant, layer: Node2D) -> void:
	scenes[scene_name] = scene
	scene.visible = false
	scene_info[scene_name] = { "layer": layer, "visible": false }
	layer.add_child(scene)
	scene.set_process_unhandled_input(false)

func add_scene_prepack(scene_name: StringName, packed_scene: PackedScene, layer: Node2D) -> void:
	if scenes.has(scene_name):
		push_error("Scene Already Exists %s" % scene_name)
		return
	var scene := packed_scene.instantiate()
	_setup_scene(scene_name, scene, layer)
	
func show_scene(scene_name: StringName, transition: int = Transition.SLIDE, side: int = Side.TOP, time: float = 0.5) -> Tween:
	if !scenes.has(scene_name):
		return
	var scene: CanvasLayer = scenes[scene_name]
	scene.set_process_unhandled_input(true)
	var mp = scene.MainPanel
	scene.visible = true
	scene_info[scene_name].visible = true
	var slide := create_tween()
	if transition != Transition.NONE:
		match(side):
			Side.TOP:
				mp.position = Vector2(0, -mp.size.y)
			Side.LEFT:
				mp.position = Vector2(-mp.size.x, 0)
			Side.RIGHT:
				mp.position = Vector2(mp.size.x, 0)
			Side.BOTTOM:
				mp.position = Vector2(0, mp.size.y)
		slide.tween_property(scene.MainPanel, "position", Vector2(0, 0), time)
		slide.set_trans(Tween.TRANS_SINE)
	else:
		scene.MainPanel.position = Vector2(0, 0)
	last_active.erase(scene_name)
	last_active.push_back(scene_name)
	return slide

func hide_scene(scene_name: StringName, transition: int = Transition.SLIDE, side: int = Side.TOP, time: float = 0.5) -> Tween:
	var scene = scenes[scene_name]
	scene.set_process_unhandled_input(false)
	var slide := create_tween()
	if transition != Transition.NONE:
		var target: Vector2
		match(side):
			Side.TOP:
				target = Vector2(0, -scene.MainPanel.size.y)
			Side.LEFT:
				target = Vector2(-scene.MainPanel.size.x, 0)
			Side.RIGHT:
				target = Vector2(scene.MainPanel.size.x, 0)
			Side.BOTTOM:
				target = Vector2(0, scene.MainPanel.size.y)
		slide.tween_property(scene.MainPanel, "position", target, time)
		slide.set_trans(Tween.TRANS_SINE)
		await slide.finished
	scene.visible = false
	scene_info[scene_name].visible = false
	last_active.erase(scene_name)
	return slide

func __cancel() -> void:
	if last_active.size() == 0:
		show_scene(default_cancel)
		return
	scenes[last_active[-1]].cancel()
	return

