extends PanelContainer
class_name ConsoleAlert

signal timedout(consoleAlert: ConsoleAlert)
var _text: String
var _timeout: float

func _init(text: String, timeout: float) -> void:
	_text = text
	_timeout = timeout

func _ready() -> void:
	#var panel := PanelContainer.new()
	var label := RichTextLabel.new()
	#var label = Label.new()
	label.bbcode_enabled = true
	label.text = _text
	label.fit_content = true
	label.scroll_active = false
	label.clip_contents = false
	label.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	#panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN | Control.SIZE_EXPAND
	#label.set_theme_type_variation(&"RichTextLabelSmall")
	print ("setting text %s" % label.text)
	var margin := MarginContainer.new()
	#var game = get_tree().get_root().get_node(^"/root/7DRL")
	#panel.material = game.BlurMaterial`
	margin.add_theme_constant_override(&"margin_left", 10)
	margin.add_theme_constant_override(&"margin_right", 4)
	margin.add_theme_constant_override(&"margin_top", 4)
	margin.add_theme_constant_override(&"margin_bottom", 4)
	add_child(margin)
	margin.add_child(label)

	await get_tree().create_timer(_timeout).timeout
	var fade := get_tree().create_tween()
	fade.tween_property(self, "modulate", Color(1,1,1,0), 0.2)
	await fade.finished
	timedout.emit(self)
	
	
	
