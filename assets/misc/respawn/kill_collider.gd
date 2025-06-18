extends Area3D

func _ready() -> void:
	self.body_entered.connect(_on_area_3d_body_entered);

func _on_area_3d_body_entered(body: Node3D) -> void:
	Player.s_instance.position = Player.s_instance.m_respawn_location;
	Player.s_instance.m_momentum = Vector2.ZERO;
