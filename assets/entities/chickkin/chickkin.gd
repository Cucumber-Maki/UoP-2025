extends EntityBase;
class_name Chickkin;

################################################################################

@onready var m_color : int = randi_range(0, 5);
@onready var m_face : int = randi_range(0, 3);
@onready var m_idle : int = randi_range(0, 3);
@onready var m_lineOffset : float = randf_range(-1.0, 1.0) * 0.15;
#
@export var m_claimed : bool = false:
	set(value):
		m_claimed = value;
		if (Player.s_instance == null): return;
		if (m_claimed):
			Player.s_instance.m_chickkins.append(self);
		else:
			Player.s_instance.m_chickkins.erase(self);
#
var m_lastPosition : Vector3 = Vector3.INF;
var m_lastMovementSpeed : float = 0;
#
var m_pathingSpeed : float = 15;
var m_currentPathDistance : float = INF;
var m_jumpTime : float = 0;
var m_jumpHeight : float = 0;
var m_jumpProgress : float = 0;

################################################################################

func _ready():
	$Model/Chickkin/Skeleton3D/Model.set_instance_shader_parameter("u_colorChoice", m_color as float);
	$Model/Chickkin/Skeleton3D/Model.set_instance_shader_parameter("u_faceChoice", m_face as float);
	setAnimationVariableDirect("parameters/Idle/blend_position", m_idle);
	m_claimed = m_claimed;

func _exit_tree() -> void:
	m_claimed = false;
	
################################################################################

func updateVisuals(delta):
	if (m_lastPosition == Vector3.INF):
		m_lastPosition = global_position;
	
	var change := global_position - m_lastPosition;
	
	var movementSpeed : float = 0;
	if (change.length_squared() > 0): 
		movementSpeed = change.length() / (m_pathingSpeed * delta);
		global_rotation.y = rotate_toward(global_rotation.y, Vector2(change.z, change.x).angle(), 1.2 * TAU * delta);
	
	m_lastMovementSpeed = move_toward(m_lastMovementSpeed, movementSpeed > 0, 10 * delta);
	setAnimationVariable("parameters/MovementSpeed/blend_amount", m_lastMovementSpeed > 0, 3 * delta);
	
	m_lastPosition = global_position;

func moveToPath(index : int, beforeDistance : float, pushback : float, delta : float) -> float:
	m_currentPathDistance += pushback;
	if (ChickkinPath.s_instance == null): return m_currentPathDistance;
	
	var targetDistance : float = max(
		ChickkinPath.s_instance.getPathDistance(index) - \
		ChickkinPath.s_instance.getActiveDistance(),
		beforeDistance + ChickkinPath.s_instance.m_followSpacing
	);
	
	if (m_currentPathDistance == INF):
		m_currentPathDistance = targetDistance;
	
	var route := ChickkinPath.s_instance.getRoute(targetDistance, m_currentPathDistance);
	var amountToMove : float = min(m_pathingSpeed * delta, m_currentPathDistance - targetDistance);
	while (!route.is_empty() && amountToMove > 0):
		var routePoint : ChickkinPath.RoutePoint = route.pop_back();
		var remainingDistance : float = m_currentPathDistance - routePoint.m_startDistance;

		match (routePoint.m_pathPoint.m_type):
			ChickkinPath.PathPointType.Ground:
				if (remainingDistance < amountToMove):
					m_currentPathDistance = routePoint.m_startDistance;
					amountToMove -= remainingDistance;
					break;
					
				m_currentPathDistance -= amountToMove;
				amountToMove = 0;
				
				var from := routePoint.m_pathPoint.m_from;
				var to := routePoint.m_pathPoint.m_to;
				var t := remap(m_currentPathDistance, routePoint.m_startDistance, routePoint.m_endDistance, 0, 1);
				global_position = to.lerp(from, t);
			
			ChickkinPath.PathPointType.Air:
				if (m_jumpTime > 0):
					if (m_jumpProgress <= 0):
						m_currentPathDistance = routePoint.m_startDistance;
						m_jumpTime = 0;
						m_jumpProgress = 0;
					else:
						m_jumpProgress -= delta / m_jumpTime;
				elif (targetDistance < routePoint.m_startDistance):
					var length := routePoint.m_endDistance - routePoint.m_startDistance;
					m_jumpTime = length / 10;
					m_jumpHeight = length * 0.4;
					m_jumpProgress = 1.0;
				else:
					amountToMove = 0;
					global_position = routePoint.m_pathPoint.m_from;
					break;
				
				var from := routePoint.m_pathPoint.m_from;
				var to := routePoint.m_pathPoint.m_to;
				var pos := to.lerp(from, m_jumpProgress);
				pos.y += sin(m_jumpProgress * PI) * m_jumpHeight;
				global_position = pos;
				
				return max(
					routePoint.m_startDistance - (ChickkinPath.s_instance.m_followSpacing + 0.05),
					route[0].m_endDistance if (route.size() > 0 && route[0].m_pathPoint.m_type == ChickkinPath.PathPointType.Air) else 0.0
				);
	
	return m_currentPathDistance;
	
