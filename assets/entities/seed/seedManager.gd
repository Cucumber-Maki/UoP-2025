extends Node
class_name SeedManager;

var remainingSeeds : int = 0;

func _ready() -> void:
	ScoreState.m_seedCount = 0;
	ScoreState.m_time = 0;

func collectSeed() -> void:
	Console.log("Seed collected.");
	ScoreState.m_seedCount += 1
	remainingSeeds -= 1;
	$CollectAudio.play()
	if (remainingSeeds <= 0):
		GameState.changeScene("res://scenes/leaderboard/leaderboard.tscn");

func _process(delta: float) -> void:
	ScoreState.m_time += delta;
