extends Node3D

signal seed_collected

func _on_area_3d_body_entered(body: Node3D) -> void:
	var playerBody := body as Player
	if playerBody != null:
		seed_collected.emit()
		queue_free()
