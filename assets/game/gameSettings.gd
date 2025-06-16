extends GameSaveableBase;

################################################################################

# NOTE: This script pertains to user settings that persists between game 
#		instances and should not be used for save-game specific data. 

################################################################################
	
var camera_analogLookSensitivity : float = 5.0;
var camera_mouseLookSensitivity : float = 5.0;
var camera_invertCameraX : bool = false;
var camera_invertCameraY : bool = false;

var volume_master : float = 0.1;
var volume_effect : float = 0.1;

################################################################################	

func getFileLocation() -> String:
	return "config.txt"

################################################################################	
