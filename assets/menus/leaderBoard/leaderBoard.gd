extends OptionMenuBase

var m_scores: Array # Array of Dictionaries: {name, seed}

################################################################################

func _on_pause_menu_on_menu_enter(menu: String) -> void:
	if (menu != "LeaderBoard"): return
	_refreshLeaderBoard()

func _refreshLeaderBoard():
	_cleanMenu()
	_createMenu()
		
func _cleanMenu():
	var children = getContentContainer().get_children()
	for child in children:
		child.free()

var m_activeLeaderboardContainer : GridContainer = null;
func getLeaderboardContainer() -> GridContainer:
	if (m_activeLeaderboardContainer == null):
		m_activeLeaderboardContainer = GridContainer.new();
		m_activeLeaderboardContainer.columns = 2;
		getContentContainer().add_child(m_activeLeaderboardContainer);
		#
		var heading_name : Label = Label.new()
		heading_name.text = "Name";
		heading_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		m_activeLeaderboardContainer.add_child(heading_name);
		var heading_seeds : Label = Label.new()
		heading_seeds.text = "Seeds"
		heading_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		m_activeLeaderboardContainer.add_child(heading_seeds);
	return m_activeLeaderboardContainer;

func _createMenu():
	addCategory("Leader Board")
	for score in m_scores:
		var content_name : Label = Label.new()
		content_name.text = "{name}".format(score);
		content_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		getLeaderboardContainer().add_child(content_name);
		var content_seeds : Label = Label.new()
		content_seeds.text = "{seeds}".format(score);
		content_seeds.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		getLeaderboardContainer().add_child(content_seeds);
		
	addButton("Exit", func(): onMenuExit.emit());

################################################################################

func _ready() -> void:
	m_scores = _loadScores()

func _loadScores() -> Array:
	return _parseData(_loadData())

func _loadData() -> String:
	var file: FileAccess = FileAccess.open(
		"user://leaderboard.json",
		FileAccess.READ
	)
	if (file == null): return ""
	return file.get_as_text(true)
	
func _parseData(jsonStr: String) -> Array:
	if jsonStr == "": jsonStr = "[]"
	var object = JSON.new()
	object.parse(jsonStr)
	return object.get_data()
