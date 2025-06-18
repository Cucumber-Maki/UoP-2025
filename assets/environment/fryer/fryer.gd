extends Node

@export var podium : Area3D;

func _ready():
	if (podium == null): return;
	podium.body_entered.connect(onChickkinBodyEntered);

func onChickkinBodyEntered(body: Node3D) -> void:
	var chickkin := body as Chickkin;
	if (chickkin == null): return;
	chickkin.yeet($Target.global_position);
	
