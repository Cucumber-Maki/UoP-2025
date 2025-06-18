extends Node

var seedCount : int = 0;
var totalSeeds : int;

func _ready() -> void:
	totalSeeds = get_children().size()


func collectSeed() -> void:
	print("Seed collected")
	seedCount += 1
