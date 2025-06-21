extends OptionMenuBase

################################################################################

func _on_pause_menu_on_menu_enter(menu: String) -> void:
	if (menu != name): return
	_refreshLeaderBoard()

func _refreshLeaderBoard():
	clearMenu()
	_createMenu()

var m_activeLeaderboardContainer : GridContainer = null;
func getLeaderboardContainer() -> GridContainer:
	if (m_activeLeaderboardContainer == null):
		m_activeLeaderboardContainer = GridContainer.new();
		m_activeLeaderboardContainer.columns = 5;
		getContentContainer().add_child(m_activeLeaderboardContainer);
		
		createLeaderBoardHeading("Rank")
		createLeaderBoardHeading("Name")
		createLeaderBoardHeading("Seeds")
		createLeaderBoardHeading("Chickmins")
		createLeaderBoardHeading("Time")
	return m_activeLeaderboardContainer;
	
func createLeaderBoardHeading(headingText: String):
	var heading : Label = Label.new()
	heading.text = " %s " % headingText;
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	m_activeLeaderboardContainer.add_child(heading);

const tab_size : int = 5;
var current_tab : int = 0;
var m_lastSize : int = -1;
var highlightTarget = null;
var scores : Array = [];

func _createMenu():
	addCategory("Leaderboard");
	
	if (LeaderboardState.leaderboard.size() != m_lastSize):
		m_lastSize = LeaderboardState.leaderboard.size()
		highlightTarget = LeaderboardState.leaderboard[-1];
		scores = LeaderboardState.leaderboard.duplicate()
	
	addTab("Seeds");
	m_activeLeaderboardContainer = null;
	var seedLeaderboard := getLeaderboardContainer();
	printLeaderboard(seedLeaderboard, "Seeds");
		
	addTab("Chickmins");
	m_activeLeaderboardContainer = null;
	var chickminsLeaderboard := getLeaderboardContainer();
	printLeaderboard(chickminsLeaderboard, "Chickmins");
	
	addTab("Time");
	m_activeLeaderboardContainer = null;
	var timeLeaderboard := getLeaderboardContainer();
	printLeaderboard(timeLeaderboard, "Time");
	
	endTab();
	
	var controls := HBoxContainer.new();
	controls.alignment = BoxContainer.ALIGNMENT_CENTER;
	var grid := GridContainer.new();
	grid.columns = 2;
	var left := Button.new();
	var right := Button.new();
	#
	left.text = " < ";
	left.button_up.connect(func():
		current_tab -= 1;
		printLeaderboard(seedLeaderboard, "Seeds");
		printLeaderboard(chickminsLeaderboard, "Chickmins");
		printLeaderboard(timeLeaderboard, "Time");
		#
		@warning_ignore("confusable_local_declaration")
		var totalTabs : int = getTotalTabs();
		left.disabled = current_tab <= 0;
		right.disabled = current_tab >= totalTabs - 1;
	);
	left.disabled = current_tab <= 0;
	grid.add_child(left);
	#
	right.text = " > ";
	right.button_up.connect(func():
		current_tab += 1;
		printLeaderboard(seedLeaderboard, "Seeds");
		printLeaderboard(chickminsLeaderboard, "Chickmins");
		printLeaderboard(timeLeaderboard, "Time");
		#
		@warning_ignore("confusable_local_declaration")
		var totalTabs : int = getTotalTabs();
		left.disabled = current_tab <= 0;
		right.disabled = current_tab >= totalTabs - 1;
	);
	var totalTabs : int = getTotalTabs();
	right.disabled = current_tab >= totalTabs - 1;
	grid.add_child(right);
	controls.add_child(grid);
	getContentContainer().add_child(controls);
	
	addButton("Exit to Main Menu", func():
		if (GameStateSwitcher.isFreshGame()):
			onMenuExit.emit();
		else:
			GameStateSwitcher.exitToMainMenu();
	);

func printLeaderboard(parent : GridContainer, type : StringName):
	if (parent == null): return;
	
	for i in range(parent.columns, parent.get_child_count()):
		parent.get_child(i).queue_free();
	
	for score in scores:
		if (!score.has("seeds")): score.seeds = 0;
		if (!score.has("chickmins")): score.chickmins = 0;
		if (!score.has("time")): score.time = 0;
	
	match type:
		"Seeds":
			scores.sort_custom(func(a, b): 
				if (a.seeds != b.seeds):
					return a.seeds > b.seeds;
				if (a.chickmins != b.chickmins):
					return a.chickmins > b.chickmins;
				return a.time < b.time;
			);
		"Chickmins":
			scores.sort_custom(func(a, b): 
				if (a.chickmins != b.chickmins):
					return a.chickmins > b.chickmins;
				if (a.seeds != b.seeds):
					return a.seeds > b.seeds;
				return a.time < b.time;
			);
		"Time":
			scores.sort_custom(func(a, b): 
				if (a.time != b.time):
					return a.time < b.time;
				if (a.seeds != b.seeds):
					return a.seeds > b.seeds;
				return a.chickmins > b.chickmins;
			);
			
	var from := current_tab * tab_size;
	var to := from + tab_size;
	var rank := from + 1
	for score in scores.slice(from, to):
		var highlight : bool = score == highlightTarget
		
		printLeaderboardCell(parent, str(rank), highlight)
		rank += 1
		printLeaderboardCell(parent, "%s" % score.name, highlight)
		printLeaderboardCell(parent, "%d" % score.seeds, highlight)
		printLeaderboardCell(parent, "%d" % score.chickmins, highlight)
		printLeaderboardCell(parent, GameStateSwitcher._getFormattedTime(score.time, 1), highlight)
		
func printLeaderboardCell(parent: GridContainer, text: String, highlight : bool):
	var content_cell : Label = Label.new()
	content_cell.text = text;
	if (highlight):
		content_cell.add_theme_color_override("font_color", Color("ffbb33"));
	content_cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	parent.add_child(content_cell);

func getTotalTabs() -> int:
	var totalTabs : int = LeaderboardState.leaderboard.size() / tab_size;
	if ((LeaderboardState.leaderboard.size() % tab_size) > 0):
		totalTabs += 1;
	return totalTabs
