extends Node3D
class_name ChickkinPath;
static var s_instance : ChickkinPath = null;

################################################################################

enum PathPointType {
	Ground,
	Air,
};

class PathPoint:
	var m_from : Vector3;
	var m_to : Vector3;
	var m_type : PathPointType;
	
	func _init(from : Vector3, to : Vector3, type : PathPointType):
		m_from = from;
		m_to = to;
		m_type = type;
		
class RoutePoint: 
	var m_pathPoint : PathPoint;
	var m_startDistance : float;
	var m_endDistance : float;
	
	func _init(pathPoint : PathPoint, startDistance : float):
		m_pathPoint = pathPoint;
		m_startDistance = startDistance;
		m_endDistance = startDistance + (m_pathPoint.m_to - m_pathPoint.m_from).length();

################################################################################

@export var m_pathMaxLength = 100.0;
@export var m_newPointThreshold = 1.0;
var m_activePathPoint : Vector3 = Vector3.ZERO;
var m_lastPathPoint : Vector3 = Vector3.INF;
var m_path : Array[PathPoint] = [];
var m_pushback : float = 0.0;
#
@export var m_followDistance = 1.2;
@export var m_followSpacing = 0.5;

################################################################################

func _ready() -> void:
	s_instance = self;
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	groundMaterial.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	groundMaterial.albedo_color = Color.RED
	airMaterial.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	airMaterial.albedo_color = Color.CYAN
	self.add_child(mesh_instance);
	
func _exit_tree() -> void:
	if (s_instance == self):
		s_instance = null;
		
################################################################################

func updatePoint(point : Vector3, leftGround : bool) -> void:
	m_activePathPoint = point;
	if (m_lastPathPoint == Vector3.INF):
		addPathPoint(m_activePathPoint);
		return;
	
	var change = m_activePathPoint - m_lastPathPoint;
	if (change.length() >= m_newPointThreshold || leftGround):
		addPathPoint(m_activePathPoint, leftGround);
		
func addPathPoint(point : Vector3, leftGround : bool = false) -> void:
	if (m_lastPathPoint == Vector3.INF):
		m_lastPathPoint = point;
		return;
	
	m_path.push_front(
		PathPoint.new(
			m_lastPathPoint,
			point, 
			PathPointType.Ground if !leftGround else PathPointType.Air
		)
	);
	m_pushback += (point - m_lastPathPoint).length();
	m_lastPathPoint = point;
	drawPath();
	
	var totalLength : float = 0;	
	for pathPoint : PathPoint in m_path:
		totalLength += (pathPoint.m_from - pathPoint.m_to).length();
	
	while (m_path.size() > 0 && totalLength > m_pathMaxLength):
		var removed : PathPoint = m_path.pop_back();
		totalLength -= (removed.m_from - removed.m_to).length();

################################################################################

func getPathDistance(index : int) -> float:
	return m_followDistance + (m_followSpacing * index);

func getActiveDistance() -> float:
	if (m_lastPathPoint == Vector3.INF): return 0;
	return (m_activePathPoint - m_lastPathPoint).length();

func getPushBack() -> float:
	var pushback = m_pushback;
	m_pushback = 0;
	return pushback;
		
func getRoute(from : float, to : float) -> Array[RoutePoint]:
	var route : Array[RoutePoint] = [];
	
	var totalDistance : float = 0;
	for pathPoint : PathPoint in m_path:
		if (totalDistance > to): break;
			
		var change := pathPoint.m_from - pathPoint.m_to;
		var length := change.length();
			
		if (from <= totalDistance + length && totalDistance < to):
			route.append(RoutePoint.new(pathPoint, totalDistance));
		
		totalDistance += length;
	
	return route;
		
################################################################################

var mesh_instance := MeshInstance3D.new()
var immediate_mesh := ImmediateMesh.new();
var groundMaterial := ORMMaterial3D.new()
var airMaterial := ORMMaterial3D.new()
func drawPath():
	if (!DebugSettings.render_chickinPaths): 
		mesh_instance.visible = false;
		return;
	
	mesh_instance.visible = true;
	immediate_mesh.clear_surfaces();
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, groundMaterial);
	for pathPoint : PathPoint in m_path:
		if (pathPoint.m_type != PathPointType.Ground): continue;
		immediate_mesh.surface_add_vertex(pathPoint.m_from);
		immediate_mesh.surface_add_vertex(pathPoint.m_to);
	immediate_mesh.surface_end()
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, airMaterial);
	for pathPoint : PathPoint in m_path:
		if (pathPoint.m_type != PathPointType.Air): continue;
		immediate_mesh.surface_add_vertex(pathPoint.m_from);
		immediate_mesh.surface_add_vertex(pathPoint.m_to);
	immediate_mesh.surface_end()
