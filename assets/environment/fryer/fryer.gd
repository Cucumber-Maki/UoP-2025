extends Node

@export var podium : Area3D;

func _ready():
	if (podium == null): return;
	podium.body_entered.connect(onChickminBodyEntered);

func onChickminBodyEntered(body: Node3D) -> void:
	var chickmin := body as Chickmin;
	if (chickmin == null): return;
	chickmin.yeet($Target.global_position);
	
