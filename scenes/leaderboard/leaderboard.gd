extends MenuStack

func _on_save_score_button_pressed() -> void:
	var name: String = $NameSubmission/GridContainer/GridContainer/NameLineEdit.text
	ScoreState.m_name = name
	if !ScoreState.submitScore():
		print(ScoreState.m_name)
		return #complain
	enterMenu("LeaderBoard")

func _on_skip_button_pressed() -> void:
	enterMenu("LeaderBoard")
