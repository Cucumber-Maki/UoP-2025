extends Control
class_name MenuStack;

################################################################################

@export var defaultMenu : String = "";

################################################################################

signal onMenuEnter(menuName : String);
signal onMenuExit;

################################################################################

func _ready():
	for c in get_children():
		# Get menu.
		var menu : MenuBase = c as MenuBase;
		if (menu == null): continue;
		# Connect.
		menu.onMenuEnter.connect(enterMenu);
		menu.onMenuExit.connect(exitMenu);
		# Make sure the menu isnt visible yet.
		menu.visible = false;
	
	# Let input fix itself.
	exitMenu();
	enterMenu(defaultMenu);

################################################################################

var activeMenu : MenuBase = null;	
var menuStack : Array[String];
func enterMenu(menu : String):
	if (menu == ""): return;
	
	# Get child menu.
	var childMenu : MenuBase = find_child(menu) as MenuBase;
	if (childMenu == null): return;
	
	# Remember currently active menu.
	if (activeMenu != null):
		activeMenu.visible = false;
		menuStack.push_back(activeMenu.name);
	
	# Switch menus.
	childMenu.visible = true;
	activeMenu = childMenu;
	if (activeMenu.m_firstSelectable != null):
		activeMenu.m_firstSelectable.grab_focus()
	onMenuEnter.emit(menu);
	
func exitMenu():
	# Hide active menu.
	if (activeMenu != null):
		activeMenu.visible = false;
	# Deal with menu pop.
	if (menuStack.size() <= 0):
		activeMenu = null;
		onMenuExit.emit();
		return;
		
	# Get child menu.
	var nextMenu : String = menuStack.pop_back();
	var childMenu : MenuBase = find_child(nextMenu) as MenuBase;
	if (childMenu == null): 
		activeMenu = null;
		return;
	
	# Set as active menu.
	activeMenu = childMenu;
	activeMenu.visible = true;
	if (activeMenu.m_firstSelectable != null):
		activeMenu.m_firstSelectable.grab_focus()
	onMenuExit.emit();
	
################################################################################
