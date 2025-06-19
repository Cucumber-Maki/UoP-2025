extends Node3D

signal seed_collected

func _ready() -> void:
	SeedManager.remainingSeeds += 1;
	seed_collected.connect(get_parent().collectSeed)

func _exit_tree() -> void:
	SeedManager.remainingSeeds -= 1;

func _on_area_3d_body_entered(body: Node3D) -> void:
	var playerBody := body as Player
	if playerBody != null:
		seed_collected.emit()
		queue_free()
