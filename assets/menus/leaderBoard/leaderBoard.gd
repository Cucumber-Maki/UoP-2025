extends OptionMenuBase

################################################################################

func _on_pause_menu_on_menu_enter(menu: String) -> void:
	if (menu != "LeaderBoard"): return
	_refreshLeaderBoard()

func _refreshLeaderBoard():
	clearMenu()
	_createMenu()

var m_activeLeaderboardContainer : GridContainer = null;
func getLeaderboardContainer() -> GridContainer:
	if (m_activeLeaderboardContainer == null):
		m_activeLeaderboardContainer = GridContainer.new();
		m_activeLeaderboardContainer.columns = 3;
		getContentContainer().add_child(m_activeLeaderboardContainer);
		
		var heading_name : Label = Label.new()
		heading_name.text = " Name ";
		heading_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		m_activeLeaderboardContainer.add_child(heading_name);
		var heading_seeds : Label = Label.new()
		heading_seeds.text = " Seeds "
		heading_seeds.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		m_activeLeaderboardContainer.add_child(heading_seeds);
		var heading_time : Label = Label.new()
		heading_time.text = " Time "
		heading_time.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		m_activeLeaderboardContainer.add_child(heading_time);
	return m_activeLeaderboardContainer;

const tab_size : int = 5;
var current_tab : int = 0;
func _createMenu():
	addCategory("Leaderboard");
	
	
	addTab("Seeds");
	var seedLeaderboard := getLeaderboardContainer();
	printLeaderboard(seedLeaderboard, "Seeds");
		
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
		printLeaderboard(timeLeaderboard, "Time");
		#
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
		printLeaderboard(timeLeaderboard, "Time");
		#
		var totalTabs : int = getTotalTabs();
		left.disabled = current_tab <= 0;
		right.disabled = current_tab >= totalTabs - 1;
	);
	var totalTabs : int = getTotalTabs();
	right.disabled = current_tab >= totalTabs - 1;
	grid.add_child(right);
	controls.add_child(grid);
	getContentContainer().add_child(controls);
	
	addButton("Exit to Main Menu", func(): GameState.changeScene("res://scenes/mainMenu/mainMenu.tscn"));

func printLeaderboard(parent : GridContainer, type : StringName):
	for i in range(parent.columns, parent.get_child_count()):
		parent.get_child(i).queue_free();
		
	var scores : Array = LeaderboardState.leaderboard;
	match type:
		"Seeds":
			scores.sort_custom(func(a, b): 
				if (a.seeds != b.seeds):
					return a.seeds > b.seeds;
				return a.time < b.time;
			);
		"Time":
			scores.sort_custom(func(a, b): 
				if (a.time != b.time):
					return a.time < b.time;
				return a.seeds > b.seeds;
			);
			
	var from := current_tab * tab_size;
	var to := from + tab_size;
	for score in scores.slice(from, to):
		var content_name : Label = Label.new()
		content_name.text = "{name}".format(score);
		content_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		parent.add_child(content_name);
		var content_seeds : Label = Label.new()
		content_seeds.text = "%d" % int(score["seeds"]);
		content_seeds.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		parent.add_child(content_seeds);
		var content_time : Label = Label.new()
		content_time.text = "%2.2f" % score.time;
		content_time.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		parent.add_child(content_time);

func getTotalTabs() -> int:
	var totalTabs : int = LeaderboardState.leaderboard.size() / tab_size;
	if ((LeaderboardState.leaderboard.size() % tab_size) > 0): 
		totalTabs += 1;
	return totalTabs
