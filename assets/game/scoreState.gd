extends Node

################################################################################

var m_name : String = "";
var m_seedCount : int = 0;
var m_time : float = 0;

################################################################################

func submitScore() -> bool:
	m_name = m_name.trim_prefix(" ").trim_suffix(" ");
	if (m_name.length() != 3): return false;
	
	LeaderboardState.addToLeaderboard(m_name, m_seedCount, m_time);
	return true;
	
