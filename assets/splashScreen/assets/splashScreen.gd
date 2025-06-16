extends Control

@export_file("*.tscn") var m_nextScene : String;

@export var m_splashTime : float = 2.5;
@export var m_splashImages : Array[Texture];

@onready var m_backgroundRect : ColorRect = $Background
@onready var m_logoRect : TextureRect = $Background/Logo

var m_remainingSplash : float = 0.0;
var m_activeSplash : int = -1;

func _ready() -> void:
	m_backgroundRect.color = ProjectSettings.get_setting("application/boot_splash/bg_color");

func _input(event):
	if (event.is_pressed() && !event.is_echo()):
		cycleToNextSplash();

func _process(delta: float) -> void:
	if (m_remainingSplash > 0.0):
		m_remainingSplash -= delta;
	else:
		cycleToNextSplash();
		
	if (m_activeSplash < m_splashImages.size()):
		m_logoRect.texture = m_splashImages[m_activeSplash];
		return;

	GameState.changeScene(m_nextScene);

func cycleToNextSplash():
	m_activeSplash += 1;
	m_remainingSplash = m_splashTime;
		
