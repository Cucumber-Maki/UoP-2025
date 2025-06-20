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
		createLeaderBoardHeading("Chickkins")
		createLeaderBoardHeading("Time")
	return m_activeLeaderboardContainer;
	
func createLeaderBoardHeading(headingText: String):
	var heading : Label = Label.new()
	heading.text = " %s " % headingText;
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	m_activeLeaderboardContainer.add_child(heading);

const tab_size : int = 5;
var current_tab : int = 0;
func _createMenu():
	addCategory("Leaderboard");
	
	addTab("Seeds");
	m_activeLeaderboardContainer = null;
	var seedLeaderboard := getLeaderboardContainer();
	printLeaderboard(seedLeaderboard, "Seeds");
		
	addTab("Chickkins");
	m_activeLeaderboardContainer = null;
	var chickkinsLeaderboard := getLeaderboardContainer();
	printLeaderboard(chickkinsLeaderboard, "Chickkins");
	
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
		printLeaderboard(chickkinsLeaderboard, "Chickkins");
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
		printLeaderboard(chickkinsLeaderboard, "Chickkins");
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
		
	var scores : Array = LeaderboardState.leaderboard;
	for score in scores:
		if (!score.has("seeds")): score.seeds = 0;
		if (!score.has("chickkins")): score.chickkins = 0;
		if (!score.has("time")): score.time = 0;
	
	match type:
		"Seeds":
			scores.sort_custom(func(a, b): 
				if (a.seeds != b.seeds):
					return a.seeds > b.seeds;
				if (a.chickkins != b.chickkins):
					return a.chickkins > b.chickkins;
				return a.time < b.time;
			);
		"Chickkins":
			scores.sort_custom(func(a, b): 
				if (a.chickkins != b.chickkins):
					return a.chickkins > b.chickkins;
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
				return a.chickkins > b.chickkins;
			);
			
	var from := current_tab * tab_size;
	var to := from + tab_size;
	var rank := from + 1
	for score in scores.slice(from, to):
		printLeaderboardCell(parent, str(rank))
		rank += 1
		printLeaderboardCell(parent, "%s" % score.name)
		printLeaderboardCell(parent, "%d" % score.seeds)
		printLeaderboardCell(parent, "%d" % score.chickkins)
		printLeaderboardCell(parent, "%2.2f" % score.time)
		
func printLeaderboardCell(parent: GridContainer, text: String):
	var content_cell : Label = Label.new()
	content_cell.text = text;
	content_cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	parent.add_child(content_cell);

func getTotalTabs() -> int:
	var totalTabs : int = LeaderboardState.leaderboard.size() / tab_size;
	if ((LeaderboardState.leaderboard.size() % tab_size) > 0):
		totalTabs += 1;
	return totalTabs
