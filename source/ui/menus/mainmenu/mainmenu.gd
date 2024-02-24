extends CanvasLayer

@onready var NewGameButton := %NewGameButton
@onready var LoadGameButton := %LoadGameButton
@onready var SettingsButton := %SettingsButton
@onready var QuitButton := %QuitButton
@onready var Game := $"/root/7DRL"
@onready var MainPanel := $CenterContainer

func _ready() -> void:
	QuitButton.pressed.connect(self._quitbutton_pressed)
	NewGameButton.pressed.connect(self._newgamebutton_pressed)
	SettingsButton.pressed.connect(self._settingsbutton_pressed)
	LoadGameButton.pressed.connect(self._loadgamebutton_pressed)
	if OS.get_name() == "Web":
		QuitButton.hide()

func _quitbutton_pressed() -> void:
	Game.quit()

func _newgamebutton_pressed() -> void:
	Game.start_new_game()

func _settingsbutton_pressed() -> void:
	PanelManager.hide_scene(&"MainMenu")
	PanelManager.show_scene(&"Settings", PanelManager.Transition.SLIDE, PanelManager.Side.RIGHT)

func _loadgamebutton_pressed() -> void:
	Game.start_load_game()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		print("main escape")
		cancel()
		get_viewport().set_input_as_handled()

func cancel() -> void:
	Game.quit()
