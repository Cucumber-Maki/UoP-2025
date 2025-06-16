extends MenuBase;
class_name OptionMenuBase;

################################################################################

func getTargetSaveable() -> GameSaveableBase:
	return null;

################################################################################

enum OptionType {
	CheckBox, Slider,
};

@onready var root : Control = $Margin/Layout;

var m_activeParentTop : Control = null;
var m_activeParentBottom : Control = null;
var m_activeTabTop : Control = null;
var m_activeTabBottom : Control = null;
var m_activeGridContainer : GridContainer = null;

################################################################################

func _ready() -> void:
	var saveable : GameSaveableBase = getTargetSaveable();
	if (saveable != null):
		onMenuExit.connect(func(): saveable.saveSaveable());
		
	get_viewport().gui_focus_changed.connect(focusUpdated);

var m_lastFocusedElement : Control = null;
var m_lastFocusedTabContainer : TabContainer = null;
func focusUpdated(element : Control) -> void:
	m_lastFocusedElement = element if visible else null;
	if (m_lastFocusedElement == null):
		m_lastFocusedTabContainer = null;
		return;
		
	var tabContainer : Control = m_lastFocusedElement;
	while (tabContainer != null):
		if (tabContainer is TabContainer):
			break;
		tabContainer = tabContainer.get_parent_control();
	m_lastFocusedTabContainer = tabContainer;

func _process(_delta: float) -> void:
	if (!visible || m_lastFocusedTabContainer == null): return;
		
	if (Input.is_action_just_released("player_menu_tab_right")):
		m_lastFocusedTabContainer.get_tab_bar().select_next_available();
		m_lastFocusedTabContainer.get_tab_bar().grab_focus();
	elif (Input.is_action_just_released("player_menu_tab_left")):
		m_lastFocusedTabContainer.get_tab_bar().select_previous_available();
		m_lastFocusedTabContainer.get_tab_bar().grab_focus();
	
################################################################################
	
func getParentContainer(top : bool = false) -> Control:
	if (m_activeParentTop == null):
		m_activeParentTop = preload("res://assets/menus/_prefabs/content.tscn").instantiate();
		#
		m_activeParentBottom = m_activeParentTop;
		while (m_activeParentBottom.get_child_count() > 0):
			m_activeParentBottom = m_activeParentBottom.get_child(0);
		#
		root.add_child(m_activeParentTop);

	return m_activeParentTop if top else m_activeParentBottom;

func getContentContainer() -> GridContainer:
	if (m_activeTabBottom != null): 
		return m_activeTabBottom;
	return getParentContainer();

func getGridContainer() -> GridContainer:
	if (m_activeGridContainer == null):
		m_activeGridContainer = GridContainer.new();
		m_activeGridContainer.columns = 2;
		getContentContainer().add_child(m_activeGridContainer);
	return m_activeGridContainer;
	
################################################################################

func addTab(tabName : StringName) -> void:
	if (m_activeTabTop == null):
		# Setup tab container.
		var tabContainer : TabContainer = preload("res://assets/menus/_prefabs/tab.tscn").instantiate();
		#
		m_activeParentBottom = tabContainer;
		while (m_activeParentBottom.get_child_count() > 0):
			m_activeParentBottom = m_activeParentBottom.get_child(0);
		#
		#if (m_activeParentTop != null):
			#m_activeParentTop.get_child(0).reparent(m_activeParentBottom);
			#m_activeParentBottom.get_child(0).name = "Unknown";
		m_activeParentTop = tabContainer;
		
		bindFirstSelectable(tabContainer.get_tab_bar());
		root.add_child(tabContainer);
	
	m_activeGridContainer = null;
	
	m_activeTabTop = preload("res://assets/menus/_prefabs/tabContent.tscn").instantiate();
	m_activeTabBottom = m_activeTabTop;
	while (m_activeTabBottom.get_child_count() > 0):
		m_activeTabBottom = m_activeTabBottom.get_child(0);
	#	
	m_activeTabTop.name = tabName;
	#
	m_activeParentBottom.add_child(m_activeTabTop);

func endTab():
	m_activeParentTop = null;
	m_activeParentBottom = null;
	m_activeTabTop = null;
	m_activeTabBottom = null;
	m_activeGridContainer = null;
	pass;
	
################################################################################

func addCategory(categoryName : StringName) -> void:
	m_activeGridContainer = null;
	
	var label : Label = Label.new();
	label.text = categoryName;
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	getContentContainer().add_child(label);

func addOption(
	optionType : OptionType, optionName : StringName, property : StringName, 
	settings : Dictionary = {}, callback : Callable = func(): pass,
) -> void:
	var label : Label = Label.new();
	label.text = optionName;
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	getGridContainer().add_child(label);
	
	var element : Control = null;	
	match (optionType):
		OptionType.Slider:
			var slider : HSlider = HSlider.new();
			slider.custom_minimum_size.x = 100;
			slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER;
			element = slider;
		OptionType.CheckBox:
			var checkbox : CheckBox = CheckBox.new();
			checkbox.alignment = HORIZONTAL_ALIGNMENT_CENTER;
			checkbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER;
			element = checkbox;
	
	for key : String in settings.keys():
		if (key is not String): continue;
		element.set(key, settings[key]);
	
	bindElementCallback(element, property, callback);
	
	getGridContainer().add_child(element);
	bindFirstSelectable(element);
	
################################################################################

func addButton(text : StringName, callback : Callable) -> void:
	m_activeGridContainer = null;
	
	var button : Button = Button.new();
	button.text = text;
	button.button_up.connect(callback);
	getContentContainer().add_child(button);
	bindFirstSelectable(button);

################################################################################

func bindElementCallback(element : Control, property : StringName, callback : Callable) -> void:
	# Safety first.
	var target : GameSaveableBase = getTargetSaveable();
	if (target == null): 
		Console.printError("Option Menu ", self.name, " parent not set.");
		return;
	if (!(property in target)): 
		Console.printWarning("Option ", property, " not found in ", target.name);
		return;
		
	# Handle based on type.
	match (element.get_class()):
		"HSlider":
			var slider : HSlider = element;
			slider.value = target.get(property);
			# TODO: Use drag_start/ended to enable / disable the stream of value changed?
			slider.value_changed.connect(func(value : float): 
				target.setProperty(property, slider.value);
				callback.call();
			);
		"CheckBox":
			var checkBox : CheckBox = element;
			checkBox.button_pressed = target.get(property);
			checkBox.pressed.connect(func(): 
				target.setProperty(property, checkBox.button_pressed);
				callback.call();
			);
		_:
			Console.printError("Option type ", element.get_class(), " has no supported GameSaveable callback.");

func bindFirstSelectable(element : Control) -> void:
	if (m_firstSelectable != null): return;
	m_firstSelectable = element;			
