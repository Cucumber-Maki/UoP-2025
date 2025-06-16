extends MenuStack

################################################################################

func _ready() -> void:
	onMenuEnter.connect(func(_menuName : String):
		if (activeMenu == null || menuStack.size() > 0): return;
		# Take user control.
		GameState.setPaused(true);
		GameState.inputActive = false;
	);
	onMenuExit.connect(func():
		if (activeMenu != null): return;
		# Reset user control.
		GameState.setPaused(false);
		GameState.inputActive = true;
	);
	
	super();

################################################################################

func _process(_delta):
	if (Input.is_action_just_pressed("player_pause") && activeMenu == null):
		# Enter pause menu.
		enterMenu("PauseMenu");
	elif (Input.is_action_just_pressed("player_menu_back") && activeMenu != null):
		activeMenu.onMenuExit.emit();

func _notification(what) -> void:
	if (what == NOTIFICATION_WM_WINDOW_FOCUS_OUT && activeMenu == null):
		enterMenu("PauseMenu");
