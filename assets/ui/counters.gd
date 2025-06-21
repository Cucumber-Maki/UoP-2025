extends Control

func _process(delta: float) -> void:
	$MarginContainer/GridContainer/Chickmins.text = "%d" % Chickmin.m_chickenCount;
	$MarginContainer/GridContainer/Seeds.text = "%d" % ScoreState.m_seedCount;
