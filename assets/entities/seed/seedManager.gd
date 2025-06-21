extends Node
class_name SeedManager;

var remainingSeeds : int = 0;

func _ready() -> void:
	ScoreState.m_seedCount = 0;
	ScoreState.m_chickminCount = 0;
	ScoreState.m_time = 0;

func collectSeed() -> void:
	Console.log("Seed collected.");
	ScoreState.m_seedCount += 1
	remainingSeeds -= 1;
	$CollectAudio.play()
	if (remainingSeeds <= 0):
		GameStateSwitcher.winGame();

func _process(delta: float) -> void:
	if (!GameState.gameActive): return;
	ScoreState.m_time += delta;
