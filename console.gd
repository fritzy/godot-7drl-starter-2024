extends CanvasLayer
class_name Console

var hidden := true
@onready var ConsolePanel := $ConsolePanel
@onready var ConsoleInput := $ConsolePanel/ConsoleArea/InputContainer/ConsoleInput
@onready var Log := $ConsolePanel/ConsoleArea/LogScroller/Log
@onready var Output := $ConsolePanel/ConsoleArea/LogScroller/Log/Output
@onready var Game := $"/root/7DRL"

var command_help: Dictionary = {}
var command_call: Dictionary = {}

const ANIM_TIME = 0.2

func _ready() -> void:
	ConsolePanel.position.y = -ConsolePanel.size.y
	ConsoleInput.connect("text_submitted", self._on_consoleinput_submitted)
	add_command("help", cmd_help, "List commands or specific command", "help [cmd]")
	add_command("start_game", Game.start_new_game, "Start a new game", "")

func log(line: String, small: bool = false) -> void:
	#Output.text = Output.text + "%s\n" % line
	var label := Label.new()
	label.text = " " + line
	if small:
		label.theme_type_variation = "HeaderSmall"
	Log.add_child(label)
	await get_tree().process_frame
	#await get_tree().create_timer(0.25).timeout
	var sc := %LogScroller as ScrollContainer
	sc.scroll_vertical = sc.get_v_scroll_bar().max_value

func cmd_help(cmd: String = "") -> String:
	var output: Array[String] = []
	for key: String in command_help:
		output.append("%s: %s" % [key, command_help[key]])
	return "\n".join(output)
	
func _on_consoleinput_submitted(new_text: String) -> void:
	if new_text == "":
		return
	var args: Array = parse_words(new_text)
	print(new_text, args)
	print(command_call)
	print(command_call.has(args[0]))
	ConsoleInput.clear()
	self.log(":: " + new_text, true)
	match args[0]:
		"print":
			self.log(" ".join(args.slice(1)))
	if command_call.has(args[0]):
		var output = command_call[args[0]].callv(args.slice(1))
		if output == null:
			output = ""
		self.log(output)

func parse_words(input) -> Array:
	var output := []
	var word: String
	var state_quote := false
	for char: String in input:
		print ("checking ", char)
		var end_word := false
		match char:
			"\"":
				if (state_quote):
					state_quote = false
					end_word = true
				else:
					state_quote = true
					end_word = true
			" ", ",":
				if !state_quote:
					end_word = true
				else:
					word = word + char
			var other_char:
				word = word + other_char
				print("added char ", other_char, word)
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

func toggle_show(animate: bool = true) -> void:
	var anim_time = ANIM_TIME if animate else 0.0
	if hidden:
		get_tree().create_tween()\
		.tween_property(ConsolePanel, "position", Vector2(0, 0), anim_time)\
		.set_trans(Tween.TRANS_SINE)
		ConsoleInput.grab_focus()
		hidden = false
	else:
		get_tree().create_tween()\
		.tween_property(ConsolePanel, "position", Vector2(0, -ConsolePanel.size.y), anim_time)\
		.set_trans(Tween.TRANS_SINE)
		ConsoleInput.release_focus()
		hidden = true

func add_command(cmd: String, callback: Callable, help: String, usage: String) -> void:
	command_help[cmd] = help
	command_call[cmd] = callback
