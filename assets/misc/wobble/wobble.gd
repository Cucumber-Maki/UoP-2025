@tool
extends SkeletonModifier3D
class_name SkeletonWobbler

@export_enum(" ") var m_bone : String = "";
@export var m_retention = 0.92;
@export var m_velocityChange = 0.99;
var m_velocity : Vector3 = Vector3.ZERO;
var m_followPoint : Vector3 = Vector3.ZERO;

func _validate_property(property: Dictionary) -> void:
	match (property.name):
		"m_bone":
			var skeleton : Skeleton3D = get_skeleton()
			if (!skeleton): return;
			property.hint = PROPERTY_HINT_ENUM;
			property.hint_string = skeleton.get_concatenated_bone_names();
	
func _ready() -> void:
	if (m_bone == ""): return;
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton: return;
	var bone_idx: int = skeleton.find_bone(m_bone)
	if (bone_idx == -1): return;
	
	var pose : Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(bone_idx);
	var targetPoint : Vector3 = pose * Vector3(0, 1, 0);
	m_followPoint = targetPoint;

func _process_modification() -> void:
	if (m_bone == ""): return;
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton: return;
	var bone_idx: int = skeleton.find_bone(m_bone)
	if (bone_idx == -1): return;
	
	var pose: Transform3D = skeleton.get_bone_global_pose(bone_idx)
	var looked_at: Transform3D = _y_look_at(pose, skeleton.global_transform.inverse() * m_followPoint);
	skeleton.set_bone_global_pose(bone_idx, Transform3D(looked_at.basis.orthonormalized(), skeleton.get_bone_global_pose(bone_idx).origin));
	
func _physics_process(delta: float) -> void:
	if (!active || m_bone == ""): return;
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton: return;
	var bone_idx: int = skeleton.find_bone(m_bone)
	if (bone_idx == -1): return;
	
	var pose : Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(bone_idx);
	var targetPoint : Vector3 = pose * Vector3(0, 1, 0);
	var change = (targetPoint - m_followPoint);
	m_followPoint += m_velocity * 0.5 * delta;
	m_velocity += change * m_velocityChange;
	m_followPoint += m_velocity * 0.5 * delta;
	m_velocity *= m_retention;
	
# Stolen... 
func _y_look_at(from: Transform3D, target: Vector3) -> Transform3D:
	var t_v: Vector3 = target - from.origin
	var v_y: Vector3 = t_v.normalized()
	var v_z: Vector3 = from.basis.x.cross(v_y)
	v_z = v_z.normalized()
	var v_x: Vector3 = v_y.cross(v_z)
	from.basis = Basis(v_x, v_y, v_z)
	return from
