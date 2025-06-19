extends Control

func _process(delta: float) -> void:
	var secs : int = floorf(fmod(ScoreState.m_time, 60.0));
	var minutes : int = floorf(fmod(ScoreState.m_time, 60.0 * 60.0) / 60.0);
	var hours : int = floorf(ScoreState.m_time / (60.0 * 60.0));
	
	var time : String = "%d" % secs;
	while (time.length() < 2):
		time = "0" + time;
	if (hours > 0 || minutes > 0): 
		time = ("%d:" % minutes) + time;
		if (hours > 0):
			while (time.length() < 5):
				time = "0" + time;
	if (hours > 0): time = ("%d:" % hours) + time;
	
	$MarginContainer/GridContainer/Timer.text = time;
