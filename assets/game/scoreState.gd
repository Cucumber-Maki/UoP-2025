extends Node

################################################################################

var m_name : String = "";
var m_seedCount : int = 0;
var m_chickkinCount : int = 0;
var m_time : float = 0;

################################################################################

func submitScore() -> bool:
	LeaderboardState.addToLeaderboard(m_name, m_seedCount, m_chickkinCount, m_time);
	return true;
	
