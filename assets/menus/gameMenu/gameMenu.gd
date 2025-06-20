extends MenuStack

################################################################################

func _ready() -> void:
	onMenuEnter.connect(func(_menuName : String):
		if (!GameState.gameActive || activeMenu == null || menuStack.size() > 0): return;
		# Take user control.
		GameState.setPaused(true);
		GameState.inputActive = false;
	);
	onMenuExit.connect(func():
		if (!GameState.gameActive || activeMenu != null): return;
		# Reset user control.
		GameState.setPaused(false);
		GameState.inputActive = true;
	);
	
	super();

################################################################################

func _process(_delta):
	if (GameState.gameActive && Input.is_action_just_pressed("player_pause") && activeMenu == null):
		# Enter pause menu.
		enterMenu("PauseMenu");
	elif (GameState.gameActive && Input.is_action_just_pressed("player_menu_back") && activeMenu != null):
		activeMenu.onMenuExit.emit();

func _notification(what) -> void:
	if (GameState.gameActive && what == NOTIFICATION_WM_WINDOW_FOCUS_OUT && activeMenu == null):
		enterMenu("PauseMenu");
