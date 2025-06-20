extends Control

func _process(delta: float) -> void:
	$MarginContainer/GridContainer/Timer.text = GameStateSwitcher._getFormattedTime(ScoreState.m_time);
