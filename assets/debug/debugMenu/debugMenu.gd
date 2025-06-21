extends OptionMenuBase;

func getTargetSaveable() -> GameSaveableBase:
	return DebugSettings;

func _ready() -> void:	
	super();

	addCategory("Debug Settings");
	
	addTab("Visual")
	addOption(OptionType.CheckBox, "Colliders Visible", "colliders_visible");
	addOption(OptionType.CheckBox, "Wireframe Rendering", "render_wireframe");
	addOption(OptionType.CheckBox, "Chickkin Path Rendering", "render_chickinPaths");
	
	addTab("Functions")
	addButton("Win Game", func(): GameStateSwitcher.winGame());
	addButton("Reset Scene", func(): GameState.resetScene());
	addButton("Restart Game", func(): GameState.restartGame());
	
	endTab()
	addButton("Exit", func(): onMenuExit.emit());
