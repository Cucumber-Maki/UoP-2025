extends OptionMenuBase

func _ready() -> void:
	super()
	addImage("res://assets/menus/mainMenu/title.png")
	#TODO playing the game and the main menu should all be within the same scene but its not for now
	addButton("Play", func(): GameStateSwitcher.s_instance.game_active = true); 
	addButton("Settings", func(): onMenuEnter.emit("SettingsMenu"));
	addButton("Leaderboard", func(): onMenuEnter.emit("LeaderBoard"), { "disabled": LeaderboardState.leaderboard.size() <= 0 });
	
	if (OS.get_name() != "Web"):
		addButton("Exit Game", func(): GameState.exitGame());
	
