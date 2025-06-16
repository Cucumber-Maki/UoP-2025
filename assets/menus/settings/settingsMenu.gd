extends OptionMenuBase;

func getTargetSaveable() -> GameSaveableBase:
	return GameSettings;

func _ready() -> void:	
	super();

	addCategory("Settings");

	addTab("Game");
	addCategory("Camera");
	addOption(OptionType.Slider, "Mouse Sensitivity", "camera_mouseLookSensitivity", { "min_value": 0.0, "max_value": 10.0, "step": 0.25 });
	addOption(OptionType.Slider, "Analog Sensitivity", "camera_analogLookSensitivity", { "min_value": 0.0, "max_value": 10.0, "step": 0.25 });
	addOption(OptionType.CheckBox, "Invert Y", "camera_invertCameraY");
	addOption(OptionType.CheckBox, "Invert X", "camera_invertCameraX");

	addTab("Audio");
	addCategory("Volume");
	addOption(OptionType.Slider, "Master Volume", "volume_master", { "min_value": 0.0, "max_value": 1.0, "step": 0.025 });
	addOption(OptionType.Slider, "Effect Volume", "volume_effect", { "min_value": 0.0, "max_value": 1.0, "step": 0.025 });
	
	endTab();
	addButton("Save & Exit", func(): onMenuExit.emit());
