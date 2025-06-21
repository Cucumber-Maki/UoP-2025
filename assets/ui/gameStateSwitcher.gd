extends Node
class_name GameStateSwitcher

static var s_instance : GameStateSwitcher = null;

@onready var mainMenu : MenuStack = $MainMenu;
@onready var gameMenu : MenuStack = $GameMenu;

@export var transitionTime : float = 3;

var game_active : bool = false;
var game_lerp : float = 0;

var m_freshGame : bool = true;

func _ready() -> void:
	s_instance = self;
	_startMenu();
	
func _exit_tree() -> void:
	if (s_instance == self):
		s_instance = null;

func _process(delta: float) -> void:
	if (game_active):
		if (game_lerp < 1.0):
			game_lerp = move_toward(game_lerp, 1, delta / transitionTime);
			while (mainMenu.activeMenu != null):
				mainMenu.exitMenu();
			if (game_lerp >= 1.0):
				_startGame();
	elif (game_lerp > 0.0):
		if (game_lerp >= 1.0):
			GameState.gameActive = false;
			GameState.inputActive = false;
			$Counters.visible = false;
			$Timer.visible = false;
		
		game_lerp = move_toward(game_lerp, 0, delta / transitionTime);
		while (gameMenu.activeMenu != null):
			gameMenu.exitMenu();
		if (game_lerp <= 0.0):
			_startMenu();	
	
	_handleCamera(delta);
		
func _startGame():
	var gamePaused = gameMenu.activeMenu != null;
	
	GameState.gameActive = true;
	GameState.inputActive = !gamePaused;
	m_freshGame = false;
	$Counters.visible = true;
	$Timer.visible = true;
	
func _startMenu():
	GameState.gameActive = false;
	GameState.inputActive = false;
	$Counters.visible = false;
	$Timer.visible = false;
	GameState.setPaused(false);
	if (mainMenu.activeMenu == null):
		mainMenu.enterMenu(mainMenu.defaultMenu);

static func isFreshGame():
	return s_instance.m_freshGame;
	
static func winGame():
	GameState.setPaused(false);
	while (s_instance.gameMenu.activeMenu != null):
		s_instance.gameMenu.exitMenu();
	s_instance.game_active = false;
	s_instance.mainMenu.enterMenu("NameSubmission");
	
static func exitToMainMenu():
	GameState.resetScene();

@export var cameraMenu : Node3D = null;
@export var cameraGame : Camera3D = null;
@export var cameraOrigin : Node3D = null;

@onready var gameCameraOffset : Transform3D = cameraGame.transform;
@onready var gameCameraGlobal : Transform3D = cameraGame.global_transform;

@export var rotationTime: float = 20;

func _handleCamera(delta):
	if (game_lerp < 1.0):
		cameraGame.global_transform = cameraMenu.global_transform.interpolate_with(gameCameraGlobal, game_lerp);
		
	if (!game_active):
		cameraOrigin.global_rotation.y += TAU * delta / rotationTime;
	
static func _getFormattedTime(time : float, decimals : int = 0) -> String:
	var secs : int = floorf(fmod(time, 60.0));
	var minutes : int = floorf(fmod(time, 60.0 * 60.0) / 60.0);
	var hours : int = floorf(time / (60.0 * 60.0));
	
	# Seconds.
	var timeStr : String = "%d" % secs;
	if (minutes > 0):
		while (timeStr.length() < 2):
			timeStr = "0" + timeStr;
	# Minutes.
	if (hours > 0 || minutes > 0): 
		timeStr = ("%d:" % minutes) + timeStr;
		if (hours > 0):
			while (timeStr.length() < 5):
				timeStr = "0" + timeStr;
	# Hours.
	if (hours > 0): 
		timeStr = ("%d:" % hours) + timeStr;

	# Decimals.
	if (decimals > 0):
		timeStr += ".%d" % (roundf(fmod(time, 1.0) * pow(10.0, decimals)) as int);
	
	return timeStr;
