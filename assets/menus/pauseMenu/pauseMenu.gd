extends OptionMenuBase;

func _ready() -> void:	
	super();

	addCategory("Game Paused");
	addButton("Resume", func(): onMenuExit.emit());
	addButton("Settings", func(): onMenuEnter.emit("SettingsMenu"));
	if (GameState.game_inDebugMode):
		addButton("Debug", func(): onMenuEnter.emit("DebugMenu"));

	addButton("Exit to Main Menu", func(): GameState.changeScene("res://scenes/mainMenu/mainMenu.tscn"));
