extends GameSaveableBase;

################################################################################	

var leaderboard : Array = [];

################################################################################	

func addToLeaderboard(playerName : String, seedCount : int, chickkinCount : int, time : float): 
	leaderboard.append({ "name": playerName, "seeds": seedCount, "chickkins": chickkinCount, "time": time });
	saveSaveable();

################################################################################	

func getFileLocation() -> String:
	return "leaderboard.txt"

################################################################################	
