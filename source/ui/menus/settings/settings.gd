extends CanvasLayer

@onready var MainPanel := $CenterContainer
@onready var Game := $"/root/7DRL"

func _ready() -> void:
	%CancelButton.pressed.connect(self._cancelbutton_pressed)
	%FixedScaleCheckbox.pressed.connect(self._fixedscale_pressed)
	%ScaleSlider.value_changed.connect(self._scaleslider_changed)
	%ApplyButton.pressed.connect(self._applybutton_pressed)
	_fixedscale_pressed()
	if OS.get_name() == "Web":
		%SettingsTabs.set_tab_disabled(1, true)

func _cancelbutton_pressed() -> void:
	cancel()
	
func _fixedscale_pressed() -> void:
	%ScaleSlider.editable = %FixedScaleCheckbox.button_pressed

func _scaleslider_changed(value: float) -> void:
	%ScaleLabel.text = "Scale %.1fx" % value

func _applybutton_pressed() -> void:
	Game.resize("%0.1f" % %ScaleSlider.value)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		print("settings escape")
		get_viewport().set_input_as_handled()
		cancel()
	
func cancel() -> void:
	PanelManager.hide_scene(&"Settings", PanelManager.Transition.SLIDE, PanelManager.Side.RIGHT)
	PanelManager.show_scene(&"MainMenu")
