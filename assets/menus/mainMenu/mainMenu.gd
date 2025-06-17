extends OptionMenuBase

func _ready() -> void:
	super()
	addImage("res://assets/menus/mainMenu/title.png")
	#TODO playing the game and the main menu should all be within the same scene but its not for now
	addButton("Play", func(): GameState.changeScene("res://scenes/game/game.tscn")); 
	addButton("Settings", func(): onMenuEnter.emit("SettingsMenu"));
	addButton("Exit Game", func(): GameState.exitGame());
	
