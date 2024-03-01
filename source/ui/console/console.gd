extends CanvasLayer
class_name Console

var hidden := true
@onready var ConsolePanel := $ConsolePanel
@onready var ConsoleInput := $ConsolePanel/ConsoleArea/InputContainer/ConsoleInput
@onready var Log := %Log
@onready var Game := $"/root/7DRL"

var command_help: Dictionary = {}
var command_call: Dictionary = {}
var command_usage: Dictionary = {}

const ANIM_TIME = 0.2

func _ready() -> void:
	ConsolePanel.position.y = -ConsolePanel.size.y
	ConsoleInput.connect("text_submitted", self._on_consoleinput_submitted)
	add_command("help", cmd_help, "List commands or specific command", "help [cmd]")
	add_command("start_game", Game.start_new_game, "Start a new game", "")
	add_command("gen", Game.reset, "Start a new game", "")
	add_command("quit", Game.quit, "Quit", "<>")
	add_command("save", Game.save, "Save", "")
	add_command("clear", cmd_clear, "Clear logs", "")
	add_command("size", cmd_size, "Set Window Size", "")
	add_command("fullscreen", cmd_fullscreen, "Toggle Fullscreen", "")
	add_command("fps", cmd_fps, "Show FPS", "")
	add_command("showpanel", cmd_showpanel, "Show a Panel or Menu", "showpanel <panel_name>")
	add_command("hidepanel", cmd_hidepanel, "Show a Panel or Menu", "hidepanel <panel_name>")

func log(line: String, show_alert: bool = true) -> void:
	var label := RichTextLabel.new()
	label.text = line
	label.scroll_active = false
	label.fit_content = true
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	#if small:
	label.set_theme_type_variation(&"RichTextLabelSmall")
	var sc := %LogScroller as ScrollContainer
	Log.add_child(label)
	print("log: %s" % line)
	if show_alert:
		var alert := ConsoleAlert.new(line, 5.0)
		Game.alerts.add_child(alert)
		Game.alerts.move_child(alert, 0)
		alert.timedout.connect(_alert_timedout)
	await get_tree().process_frame
	await get_tree().create_timer(0.25).timeout
	sc.ensure_control_visible(label)
	#sc.scroll_vertical = sc.get_v_scroll_bar().max_value as int

func _alert_timedout(alert: ConsoleAlert) -> void:
	print("timed out %s" % alert._text)
	var h := alert.size.y
	var idx := alert.get_index()
	var control := Control.new()
	control.set_custom_minimum_size(Vector2(0, h))
	Game.alerts.remove_child(alert)
	alert.queue_free()
	Game.alerts.add_child(control)
	Game.alerts.move_child(control, idx)
	var shrink := get_tree().create_tween()
	shrink.tween_method(control.set_custom_minimum_size, Vector2(0, h), Vector2(0, 0), .2)
	await shrink.finished
	control.queue_free()

func cmd_showpanel(panel_name: StringName) -> String:
	PanelManager.show_scene(panel_name)
	return "show panel %s" % panel_name

func cmd_hidepanel(panel_name: StringName) -> String:
	PanelManager.hide_scene(panel_name)
	return "hide panel %s" % panel_name
	

func cmd_help(cmd: String = "") -> String:
	var output: Array[String] = []
	if cmd != "" and command_help.has(cmd):
		output.append("%s:\n%s\nUsage: %s" % [cmd, command_help[cmd], command_usage[cmd]])
	else:
		for key: String in command_help:
			output.append("%s: %s" % [key, command_help[key]])
	return "\n".join(output)

func cmd_clear() -> String:
	for child in %Log.get_children():
		%Log.remove_child(child)
		child.queue_free()
	return ""

func cmd_size(sizeArg: String = "") -> String:
	var results: Array = Game.resize(sizeArg)
	return "Window Resized %s %0.1fx" % results

func cmd_fullscreen() -> String:
	var mode: Window.Mode = Game.window.get_mode()
	if (mode != Window.Mode.MODE_WINDOWED):
		Game.window.set_mode(Game.window.MODE_WINDOWED)
		cmd_size()
	else:
		Game.window.set_mode(Game.window.MODE_EXCLUSIVE_FULLSCREEN)
	return "toggled fullscreen"

func cmd_fps() -> String:
	return "fps: %d %d" % [Engine.get_frames_per_second(), DisplayServer.screen_get_refresh_rate()]
	
func _on_consoleinput_submitted(new_text: String) -> void:
	if new_text == "":
		return
	var args: Array = parse_words(new_text)
	ConsoleInput.clear()
	self.log("> " + new_text, false)
	if args[0] == "print":
		self.log(" ".join(args.slice(1)))
	elif command_call.has(args[0]):
		var output: Variant = command_call[args[0]].callv(args.slice(1))
		if output == null:
			output = ""
		self.log(output)
	else:
		self.log("command not found: %s" % args[0])

func parse_words(input: String) -> Array:
	var output := []
	var word: String
	var state_quote := false
	var escaping := false
	for chara: String in input:
		var end_word := false
		match chara:
			"\\":
				if escaping:
					word = word + "\\"
					escaping = false
				else:
					escaping = true
			"\"":
				if escaping:
					word = word + "\""
					escaping = false
				elif (state_quote):
					state_quote = false
					end_word = true
				else:
					state_quote = true
					end_word = true
			" ", ",":
				if !state_quote:
					end_word = true
				else:
					word = word + chara
				escaping = false
			var other_char:
				word = word + other_char
				escaping = false
		if end_word:
			end_word = false
			word.strip_edges()
			if word != "":
				output.append(word)
				word = ""
	if word != "":
		output.append(word)
	return output

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_console"):
		toggle_show()
		#get_tree().set_input_as_handled()
		get_viewport().set_input_as_handled()
	if event.is_action("ui_cancel") and hidden == false:
		toggle_show()
		get_viewport().set_input_as_handled()

func toggle_show(animate: bool = true) -> void:
	var anim_time := ANIM_TIME if animate else 0.0
	var slide := create_tween()
	if hidden:
		slide.tween_property(ConsolePanel, "position", Vector2(0, 0), anim_time)\
		.set_trans(Tween.TRANS_SINE)
		ConsoleInput.grab_focus()
		hidden = false
		# immediately visible when animating to show
		visible = true
	else:
		slide.tween_property(ConsolePanel, "position", Vector2(0, -ConsolePanel.size.y), anim_time)\
		.set_trans(Tween.TRANS_SINE)
		ConsoleInput.release_focus()
		hidden = true
		# wait for it to slide off screen before setting invisible
		await slide.finished
		# hidden might have changed by now if they're toggling quickly
		# so don't set specifically to false
		visible = !hidden 

func add_command(cmd: String, callback: Callable, help: String, usage: String) -> void:
	command_help[cmd] = help
	command_call[cmd] = callback
	command_usage[cmd] = usage
