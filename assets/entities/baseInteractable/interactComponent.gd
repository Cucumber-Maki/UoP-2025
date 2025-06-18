extends Area3D
class_name InteractComponent;

signal interactTrigger();

func _ready() -> void:
	pass;

###########################

func interact():
	interactTrigger.emit()
###########################


func _on_body_entered(body: Node3D) -> void:
	var playerBody := body as Player
	if playerBody != null:
		playerBody.addInteractableArea(self);


func _on_body_exited(body: Node3D) -> void:
	var playerBody := body as Player
	if playerBody != null:
		playerBody.removeInteractableArea(self);
