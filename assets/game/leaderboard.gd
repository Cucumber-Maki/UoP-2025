extends GameSaveableBase;

################################################################################	

var leaderboard : Array = [];

################################################################################	

func addToLeaderboard(name : String, seedCount : int, time : float): 
	leaderboard.append({ "name": name, "seeds": seedCount, "time": time });
	saveSaveable();

################################################################################	

func getFileLocation() -> String:
	return "leaderboard.txt"

################################################################################	
