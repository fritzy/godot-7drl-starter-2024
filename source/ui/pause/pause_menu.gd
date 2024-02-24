extends CanvasLayer

@onready var MainPanel := $CenterContainer

func _ready() -> void:
	%QuitButton.pressed.connect(_quitbutton_pressed)
	%QuitToDesktopButton.pressed.connect(_quittodesktopbutton_pressed)
	%ResumeButton.pressed.connect(_resume)
	if OS.get_name() == "Web":
		%QuitToDesktopButton.hide()

func _quitbutton_pressed() -> void:
	PanelManager.hide_scene(&"PauseMenu", PanelManager.Transition.SLIDE, PanelManager.Side.BOTTOM)
	PanelManager.show_scene(&"MainMenu")
	
func _quittodesktopbutton_pressed() -> void:
		get_tree().get_root().get_node("7DRL").quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		print("pause escape")
		_resume()


func _resume() -> void:
	PanelManager.hide_scene(&"PauseMenu", PanelManager.Transition.SLIDE, PanelManager.Side.BOTTOM)
	get_viewport().set_input_as_handled()
	get_tree().get_root().get_node("7DRL").resume()
