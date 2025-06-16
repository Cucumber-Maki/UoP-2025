extends OptionMenuBase;

func getTargetSaveable() -> GameSaveableBase:
	return DebugSettings;

func _ready() -> void:	
	super();

	addCategory("Debug Settings");
	addOption(OptionType.CheckBox, "Colliders Visible", "colliders_visible");
	addOption(OptionType.CheckBox, "Wireframe Rendering", "render_wireframe");
	addButton("Save & Exit", func(): onMenuExit.emit());
