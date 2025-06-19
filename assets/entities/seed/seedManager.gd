extends Node
class_name SeedManager;

static var remainingSeeds : int = 0;

func _ready() -> void:
	ScoreState.m_seedCount = 0;
	ScoreState.m_time = 0;

func collectSeed() -> void:
	Console.log("Seed collected.");
	ScoreState.m_seedCount += 1

func _process(delta: float) -> void:
	ScoreState.m_time += delta;
	
