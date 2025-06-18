extends Node3D

@export var m_respawn_node: Node3D;
var m_player_collided: bool = false;

func _ready() -> void:
	self.body_entered.connect(_on_area_3d_body_entered);
	self.body_exited.connect(_on_area_3d_body_exited);

func _physics_process(delta: float) -> void:
	if (!m_player_collided): return;
	if (!Player.s_instance.isGrounded()): return;
	Player.s_instance.m_respawn_location = m_respawn_node.global_position;
	m_player_collided = false;
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	m_player_collided = true;
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	m_player_collided = false;
