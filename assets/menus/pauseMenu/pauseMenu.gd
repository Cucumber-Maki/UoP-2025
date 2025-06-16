extends OptionMenuBase;

func _ready() -> void:	
	super();

	addCategory("Game Paused");
	addButton("Resume", func(): onMenuExit.emit());
	addButton("Settings", func(): onMenuEnter.emit("SettingsMenu"));
	if (OS.is_debug_build()):
		addButton("Debug", func(): onMenuEnter.emit("DebugMenu"));
	addButton("Exit Game", func(): GameState.exitGame());
