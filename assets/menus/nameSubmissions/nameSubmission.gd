extends MenuBase

@onready var m_lineEdit : LineEdit = $Margin/Layout/Content/VBoxContainer/GridContainer/NameLineEdit;
@onready var m_submitButton : Button = $Margin/Layout/Content/VBoxContainer/SubmitButton;
@onready var m_skipButton : Button = $Margin/Layout/Content/VBoxContainer/SkipButton;

func _ready() -> void:
	var ms := get_parent() as MenuStack;
	ms.onMenuEnter.connect(func(a_name):
		if (a_name != name): return;
		$Margin/Layout/Content/VBoxContainer/Panel/HBoxContainer/Scores/Seeds.text = "%d" % ScoreState.m_seedCount;
		$Margin/Layout/Content/VBoxContainer/Panel/HBoxContainer/Scores/Chickkins.text = "%d" % ScoreState.m_chickkinCount;
		$Margin/Layout/Content/VBoxContainer/Panel/HBoxContainer/Scores/Time.text = "%2.2f" % ScoreState.m_time;
	);
	
	m_firstSelectable = m_skipButton;
	
	m_lineEdit.text_changed.connect(checkText);
	checkText(m_lineEdit.text);
	
	m_lineEdit.text_submitted.connect(func(str): _on_save_score_button_pressed());
	m_submitButton.button_up.connect(_on_save_score_button_pressed);
	m_skipButton.button_up.connect(_on_skip_button_pressed);

func checkText(t : String):
	const allowedCharacters : String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	var old_caret_position = m_lineEdit.caret_column;
	
	for c in t:
		if (allowedCharacters.contains(c)): continue;
		t = t.replace(String(c), "");
		
	m_lineEdit.text = t;
	m_lineEdit.caret_column = old_caret_position;
	
	m_submitButton.disabled = m_lineEdit.text.length() != 3;

func _on_save_score_button_pressed() -> void:
	var name: String = m_lineEdit.text
	ScoreState.m_name = name
	if !ScoreState.submitScore():
		return #complain
	onMenuEnter.emit("LeaderBoard")

func _on_skip_button_pressed() -> void:
	onMenuEnter.emit("LeaderBoard")
