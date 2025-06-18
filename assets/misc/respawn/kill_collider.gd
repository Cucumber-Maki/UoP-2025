extends Area3D

@export var circle_wipe_animation: AnimationPlayer;

func _ready() -> void:
	self.body_entered.connect(_on_area_3d_body_entered);

func _on_area_3d_body_entered(body: Node3D) -> void:
	circle_wipe_animation.play("circle_fade");
