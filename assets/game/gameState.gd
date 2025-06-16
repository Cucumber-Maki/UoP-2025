extends Node

################################################################################

# NOTE: This script pertains to game settings which only last for as long as the
#		game instance is running. 

################################################################################
	
var gameActive : bool = true; # Only true whilst gameplay is happening.
var inputActive : bool = false:
	set(value):
		if (inputActive == value): return;
		inputActive = value;
		_updateMouseVisibility();
var isUsingController : bool = false:
	set(value):
		if (isUsingController == value): return;
		isUsingController = value;
		_updateMouseVisibility();

################################################################################
# Common functions.

func isMouseLocked() -> bool:
	return inputActive || isUsingController;
	
func isPaused() -> bool:
	return get_tree().paused;

func setPaused(paused : bool) -> void:
	get_tree().paused = paused;

func changeScene(scenePath : StringName)  -> void:
	setPaused(false);
	get_tree().change_scene_to_file(scenePath);

func restartGame() -> void:
	resetState();
	changeScene(ProjectSettings.get_setting("application/run/main_scene"));

func resetState() -> void:
	var defaultProperties : GameState = self.get_script().new();
	for rawProperty in self.get_script().get_script_property_list():
		var property : String = rawProperty.name;
		if (self.get(property) != defaultProperties.get(property)):
			self.set(property, defaultProperties.get(property));

func exitGame() -> void:
	get_tree().quit();

################################################################################

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS;
	#process_priority = -1;

func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouse):
		isUsingController = false;
	elif (event is InputEventJoypadButton or InputEventJoypadMotion):
		isUsingController = true;
	
func _updateMouseVisibility() -> void:
	var locked : bool = isMouseLocked();
	
	# Skip if already equal to lock status.
	var currentLockStatus = Input.mouse_mode != Input.MOUSE_MODE_VISIBLE;
	if (locked == currentLockStatus): return;
	
	# Set mouse lock status.
	Input.mouse_mode =  Input.MOUSE_MODE_CAPTURED if locked else Input.MOUSE_MODE_VISIBLE;
