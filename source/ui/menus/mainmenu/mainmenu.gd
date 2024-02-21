extends CanvasLayer

@onready var NewGameButton := %NewGameButton
@onready var LoadGameButton := %LoadGameButton
@onready var OptionsButton := %OptionsButton
@onready var QuitButton := %QuitButton
@onready var Game := $"/root/7DRL"

func _ready() -> void:
	QuitButton.pressed.connect(self._quitbutton_pressed)
	NewGameButton.pressed.connect(self._newgamebutton_pressed)
	OptionsButton.pressed.connect(self._optionsbutton_pressed)
	LoadGameButton.pressed.connect(self._loadgamebutton_pressed)
	if OS.get_name() == "Web":
		QuitButton.hide()

func _quitbutton_pressed() -> void:
	Game.quit()

func _newgamebutton_pressed() -> void:
	Game.start_new_game()

func _optionsbutton_pressed() -> void:
	Game.start_options()

func _loadgamebutton_pressed() -> void:
	Game.start_load_game()
