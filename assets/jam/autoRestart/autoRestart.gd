extends Control

@export var m_timeout : float = 45.0; # Total time to restart.
@export var m_warningDuration : float = 15.0;

@onready var m_remainingTime : float = m_timeout;
@onready var m_targetLabel : Label = $Margin/Label
@onready var m_baseString : String = m_targetLabel.text;

func _input(event):
	if (event is InputEventMouseMotion):
		# Mouse moved!
		m_remainingTime = m_timeout;

func _process(delta):
	# Update time.
	if (!GameState.gameActive || Input.is_anything_pressed()):
		# Interaction!! Yippeeee!
		m_remainingTime = m_timeout;
	else:
		# No intentional interaction :(
		m_remainingTime -= delta;
	
	# Reset game.
	if (m_remainingTime <= 0 || Input.is_action_just_pressed("game_restart")):
		GameState.restartGame();
	# Update visuals.
	elif (m_remainingTime <= m_warningDuration):
		visible = true;
		m_targetLabel.text = m_baseString % String.num(floor(m_remainingTime), 0);
	else:
		visible = false;
