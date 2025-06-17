extends Area3D
class_name BaseInteractable;

func _ready() -> void:
	add_to_group("Interactables")


###########################

# template function, overwrite me!
func interact() -> void:
	pass;
	
###########################


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.addInteractableArea(self);


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.removeInteractableArea(self);
