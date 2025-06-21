extends Control

func _process(delta: float) -> void:
	$MarginContainer/GridContainer/Chickmins.text = "%d" % ScoreState.m_chickminCount;
	$MarginContainer/GridContainer/Seeds.text = "%d" % ScoreState.m_seedCount;
