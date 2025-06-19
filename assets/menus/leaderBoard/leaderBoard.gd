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

func _createMenu():
	addCategory("Leader Board")
	for score in m_scores:
		var label : Label = Label.new()
		label.text = "Name: {name}, Seeds: {seeds}".format(score)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		getContentContainer().add_child(label)
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
