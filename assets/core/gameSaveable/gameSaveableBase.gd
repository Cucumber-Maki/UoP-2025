extends Node;
class_name GameSaveableBase;

################################################################################

# NOTE: This script is the basis for saving and loading data between game 
# 		instances. All properties in this script are automatically included into
#		the saved data.

################################################################################

func getFileLocation() -> String:
	# NOTE: This function is intended to be inherited and overwritten.
	Console.printError(self.name, " file location not specified.");
	return "";

func getFolderLocation() -> String:
	return "user://";
	
################################################################################
	
func _ready():
	loadSaveable();
	
################################################################################

signal onValueChanged(name : String);
func setProperty(propertyName : StringName, value : Variant):
	# Safety first.
	if (!(propertyName in self)): return;
	
	# Compare values.
	if (get(propertyName) == value): return;
	
	# Debug print.
	Console.log("Set ", self.name, ".", propertyName, " to ", value, ".");
	
	# Update value.
	set(propertyName, value);
	onValueChanged.emit(propertyName);

func bindValueChanged(propertyName : StringName, callback : Callable):
	onValueChanged.connect(func(a_propertyName): 
		if (a_propertyName == propertyName): 
			match (callback.get_argument_count()):
				0:
					callback.call();
				1:
					callback.call(get(propertyName));
	);

################################################################################

func saveSaveable():
	# Safety first.
	var fileLocation : String = getFileLocation();
	if (fileLocation == null || fileLocation == ""): return; 
	fileLocation = getFolderLocation().path_join(fileLocation);
	
	# Information to store.
	var information : Dictionary = {};
	var rawProperties : Array = self.get_script().get_script_property_list();
	var defaultProperties : GameSaveableBase = self.get_script().new();
	for i in range(1, rawProperties.size() - 1):
		var value = get(rawProperties[i].name);
		
		if (defaultProperties.get(rawProperties[i].name) != value):
			information[rawProperties[i].name] = value;
		
	# Ignore if no information is to be saved.
	if (information.size() <= 0): 
		# Remove previous save file if it exists.
		if (FileAccess.file_exists(fileLocation)):
			DirAccess.remove_absolute(fileLocation);
			Console.log("Removed ", self.name, " file due to all values matching defaults.");
		return;
	
	# Make sure folder exists.
	if (!DirAccess.dir_exists_absolute(getFolderLocation())):
		DirAccess.make_dir_recursive_absolute(getFolderLocation());
	
	# Get information string.
	var informationString : String = JSON.stringify(information);
	
	# Check if information changed.
	var loadFile : FileAccess = FileAccess.open(fileLocation, FileAccess.READ);
	if (loadFile != null):
		var fileContents : String = loadFile.get_as_text(true).replace("\n", "");
		
		# No need to save if the same.
		if (fileContents == informationString):
			return;
		
	
	# Open file.
	var saveFile : FileAccess = FileAccess.open(fileLocation, FileAccess.WRITE);
	if (saveFile == null):
		Console.printError(self.name, " failed to open save file '", fileLocation, "'")
		return;
	
	# Store information.
	saveFile.store_string(informationString);
	saveFile.close();

	# Debug log.	
	Console.printSuccess(self.name, " successfully saved to file '", fileLocation, "'.");

func loadSaveable():
	# Safety first.
	var fileLocation : String = getFileLocation();
	if (fileLocation == null || fileLocation == ""): return; 
	fileLocation = getFolderLocation() + fileLocation;
	
	# Open file.
	if (!FileAccess.file_exists(fileLocation)): return;
	var loadFile : FileAccess = FileAccess.open(fileLocation, FileAccess.READ);
	
	# Load information.
	var json : JSON = JSON.new();
	var parsedData = json.parse(loadFile.get_as_text(true).replace("\n", ""));
	if (parsedData != OK):
		Console.printError(self.name, " failed to parse file '", fileLocation, "'.");
		return;
	
	# Set information.
	var information : Variant = json.get_data();
	for k : String in information.keys():
		if (k in self):
			# Get value.
			var value = information[k];
			
			if (self.get(k) != value):
				# Output.
				Console.log(self.name, " value ", k, " set to ", value, ".");
				# Set value.
				self.set(k, value);
	
	# Close file.
	loadFile.close();
	
	# Debug log.
	Console.printSuccess(self.name, " successfully loaded from file '", fileLocation, "'.");
	
################################################################################
