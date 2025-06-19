extends Control

func _process(delta: float) -> void:
	$MarginContainer/GridContainer/Chickkins.text = "%d" % Chickkin.m_chickenCount;
	$MarginContainer/GridContainer/Seeds.text = "%d" % ScoreState.m_seedCount;
