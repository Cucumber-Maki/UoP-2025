extends EntityBase;
class_name Chickmin;

static var m_chickenCount : int = 0;

################################################################################

signal onClaim;
signal onYeet;

################################################################################

const c_colorTypeCount = 6;
const c_faceTypeCount = 4;
const c_idleTypeCount = 4;
@onready var m_color : int = randi_range(0, c_colorTypeCount - 1);
@onready var m_face : int = randi_range(0, c_faceTypeCount - 1);
@onready var m_idle : int = randi_range(0, c_idleTypeCount - 1);
static var s_chikkinMaterials : Array[ShaderMaterial] = [];
#
@export var m_claimed : bool = false:
	set(value):
		if (m_claimed == value): return;
		m_claimed = value;
		
		if ((Player.s_instance == null || ChickminPath.s_instance == null) && m_claimed): 
			m_claimed = false;
			return;
		
		if (m_claimed):
			Player.s_instance.m_chickmins.push_front(self);
			global_position = Player.s_instance.global_position;
			global_rotation.y = PI - Player.s_instance.m_currentMovementAngle;
			m_currentPathDistance = ChickminPath.s_instance.getPathDistance(0);
			setAnimationVariableDirect("parameters/Claimed/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);
			onClaim.emit();
		else:
			Player.s_instance.m_chickmins.erase(self);
#
var m_lastPosition : Vector3 = Vector3.INF;
var m_lastMovementSpeed : float = 0;
#
var m_pathingSpeed : float = 15;
var m_currentPathDistance : float = 0;
var m_jumpTime : float = 0;
var m_jumpHeight : float = 0;
var m_jumpProgress : float = 0;

################################################################################

func _ready():
	$Model/Chickkin/Skeleton3D/Model.set_surface_override_material(0, getMaterial());
	setAnimationVariableDirect("parameters/Idle/blend_position", m_idle);
	m_claimed = m_claimed;
	m_chickenCount += 1;
	
	global_position += Vector3(randfn(-1, 1), 0, randfn(-1, 1)).normalized() * 0.5;
	global_rotation.y += randfn(0, TAU);

func _exit_tree() -> void:
	m_claimed = false;
	m_chickenCount -= 1;
	if (m_isYeeting):
		ScoreState.m_chickminCount += 1;
	if (m_isYeeting && m_chickenCount <= 0):
		GameStateSwitcher.winGame();
		
	
func _physics_process(delta: float) -> void:
	handleYeet(delta);
	
################################################################################

func getMaterial() -> Material:
	var materialIndex : int = \
		m_color + \
		(m_face * c_colorTypeCount);
		
	if (materialIndex < s_chikkinMaterials.size() && \
		s_chikkinMaterials[materialIndex] != null): return s_chikkinMaterials[materialIndex];
	
	while (materialIndex >= s_chikkinMaterials.size()):
		s_chikkinMaterials.append(null);
	
	var mat : ShaderMaterial = preload("res://assets/entities/chickmin/chickmin.tres").duplicate();
	mat.set_shader_parameter("u_colorChoice", m_color as float);
	mat.set_shader_parameter("u_faceChoice", m_face as float);
	
	s_chikkinMaterials[materialIndex] = mat;
	return s_chikkinMaterials[materialIndex];
	
################################################################################
	
func updateVisuals(delta):
	if (m_lastPosition == Vector3.INF):
		m_lastPosition = global_position;
	
	var change := global_position - m_lastPosition;
	
	var movementSpeed : float = 0;
	if (change.length() > 0.1 * delta): 
		movementSpeed = change.length() / (m_pathingSpeed * delta);
		global_rotation.y = rotate_toward(global_rotation.y, Vector2(change.z, change.x).angle(), 1.2 * TAU * delta);
	
	m_lastMovementSpeed = move_toward(m_lastMovementSpeed, movementSpeed > 0, 10 * delta);
	setAnimationVariable("parameters/MovementSpeed/blend_amount", m_lastMovementSpeed > 0, 3 * delta);
	
	m_lastPosition = global_position;

func moveToPath(index : int, beforeDistance : float, pushback : float, delta : float) -> float:
	if (ChickminPath.s_instance == null): return 0;
	if (m_isYeeting): 
		print("yeeting but like,, not working???");
		return -INF;
	m_currentPathDistance += pushback;
	
	var targetDistance : float = max(
		ChickminPath.s_instance.getPathDistance(index) - \
		ChickminPath.s_instance.getActiveDistance(),
		beforeDistance + ChickminPath.s_instance.m_followSpacing
	);
	
	if (m_currentPathDistance <= targetDistance): 
		return targetDistance;
	
	var route := ChickminPath.s_instance.getRoute(targetDistance, m_currentPathDistance);
	var amountToMove : float = min(m_pathingSpeed * delta, m_currentPathDistance - targetDistance);
	while (!route.is_empty() && amountToMove > 0):
		var routePoint : ChickminPath.RoutePoint = route.pop_back();
		var remainingDistance : float = m_currentPathDistance - routePoint.m_startDistance;

		match (routePoint.m_pathPoint.m_type):
			ChickminPath.PathPointType.Ground:
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
			
			ChickminPath.PathPointType.Air:
				var from := routePoint.m_pathPoint.m_from;
				var to := routePoint.m_pathPoint.m_to;
				var startDistance := routePoint.m_startDistance;
				var endDistance := routePoint.m_endDistance;
				
				# Merge!!
				while (!route.is_empty() && route[-1].m_pathPoint.m_type == ChickminPath.PathPointType.Air):
					var r : ChickminPath.RoutePoint = route.pop_back();
					to = r.m_pathPoint.m_to;
					startDistance = r.m_startDistance;
				
				if (m_jumpTime > 0):
					if (m_jumpProgress <= 0):
						m_currentPathDistance = startDistance;
						m_jumpTime = 0;
						m_jumpProgress = 0;
					else:
						m_jumpProgress -= delta / m_jumpTime;
				elif (targetDistance < startDistance):
					var length := (to - from).length();
					m_jumpTime = length / 10;
					m_jumpHeight = length * 0.4;
					m_jumpProgress = 1.0;
				else:
					amountToMove = 0;
					global_position = from;
					break;
				
				var pos := to.lerp(from, m_jumpProgress);
				pos.y += sin(m_jumpProgress * PI) * m_jumpHeight;
				global_position = pos;
				
				return targetDistance;
	return m_currentPathDistance;
	
func yeet(target : Vector3):
	if (m_isYeeting): return;
	
	var length := (target - global_position).length();
	m_jumpTime = length / 10;
	m_jumpHeight = length * 0.4;
	m_jumpProgress = 1.0;
	
	m_yeetFrom = global_position;
	m_yeetTo = target;
	
	m_isYeeting = true;
	onYeet.emit();
	
var m_isYeeting : bool = false;
var m_yeetFrom : Vector3;
var m_yeetTo : Vector3;
func handleYeet(delta : float) -> void:
	if (!m_isYeeting): return;
	
	if (m_jumpTime > 0):
		if (m_jumpProgress <= 0):
			queue_free();
			return;
		else:
			m_jumpProgress -= delta / m_jumpTime;
		
	var pos := m_yeetTo.lerp(m_yeetFrom, m_jumpProgress);
	pos.y += sin(m_jumpProgress * PI) * m_jumpHeight;
	global_position = pos;

################################################################################

func onPlayerClaim(body: Node3D) -> void:
	m_claimed = true;
