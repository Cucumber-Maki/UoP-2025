extends Node

################################################################################

# NOTE: This script pertains to game settings which only last for as long as the
#		game instance is running. 

################################################################################
	
var gameActive : bool = false; # Only true whilst gameplay is happening.
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
var game_inDebugMode : bool = false:
	set(value):
		if (game_inDebugMode == value): return;
		game_inDebugMode = value;
		resetScene();

################################################################################
# Common functions.

func isMouseLocked() -> bool:
	return inputActive || isUsingController;
	
func isPaused() -> bool:
	return get_tree().paused;

func setPaused(paused : bool) -> void:
	get_tree().paused = paused;

func resetScene():
	get_tree().call_deferred("reload_current_scene")

func changeScene(scenePath : StringName) -> void:
	setPaused(false);
	inputActive = false;
	call_deferred("_changeScene", scenePath);
func _changeScene(scenePath : StringName) -> void:
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
	game_inDebugMode = OS.is_debug_build();
	#process_priority = -1;

func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouse):
		isUsingController = false;
	elif (event is InputEventJoypadButton):
		isUsingController = true;
	elif (event is InputEventJoypadMotion and (event as InputEventJoypadMotion).axis_value > 0.5):
		isUsingController = true;
		
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("game_fullscreen")):
		if (DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#
	if (Input.is_action_just_pressed("game_debugMode")):
		game_inDebugMode = !game_inDebugMode;
	
func _updateMouseVisibility() -> void:
	var targetState : Input.MouseMode = Input.MOUSE_MODE_VISIBLE;
	if (inputActive): 
		targetState = Input.MOUSE_MODE_CAPTURED;
	elif (isUsingController):
		targetState = Input.MOUSE_MODE_HIDDEN;
	
	# Skip if already equal to lock status.
	if (Input.mouse_mode == targetState): return;
	Input.mouse_mode = targetState;
