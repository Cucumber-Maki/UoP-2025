extends GameSaveableBase;

################################################################################	

var leaderboard : Array = [];

################################################################################	

func addToLeaderboard(playerName : String, seedCount : int, time : float): 
	leaderboard.append({ "name": playerName, "seeds": seedCount, "time": time });
	saveSaveable();

################################################################################	

func getFileLocation() -> String:
	return "leaderboard.txt"

################################################################################	
