extends GameSaveableBase;

################################################################################	

var leaderboard : Array = [];

################################################################################	

func addToLeaderboard(playerName : String, seedCount : int, chickminCount : int, time : float): 
	leaderboard.append({ "name": playerName, "seeds": seedCount, "chickmins": chickminCount, "time": time });
	saveSaveable();

################################################################################	

func getFileLocation() -> String:
	return "leaderboard.txt"

################################################################################	
