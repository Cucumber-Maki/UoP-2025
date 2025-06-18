extends MovementBase;
class_name Player;
static var s_instance : Player = null;

################################################################################

# Animations
@export_group("Animations", "m_animation")
@export var m_animationGroundBlendSpeed : float = 8.0;
@export var m_animationGroundSpeedScale : float = 2.0;
@export var m_animationAirBlendSpeed : float = 2.0;
@export var m_animationAirStateBlendSpeed : float = 7.0;
@export var m_animationTurnSpeed : float = 2.0;
@export var m_animationTurnExponent : float = 2.0;
@export var m_animationJumpScaling : float = 1.5;
@export var m_animationJumpExponent : float = 1.5;
# Roll
@export_group("Abilities", "m_abilities")
@export_subgroup("Roll", "m_ability_roll")
@export var m_ability_rollUnlocked : bool = false;
@export var m_ability_rollImpulse : Vector2 = Vector2(12, 4);
var m_ability_rollAvailable : bool = false;
#
@onready var m_cameraOrigin : Node3D = $CameraOrigin;
@onready var m_cameraAngle : Vector2 = Vector2(m_cameraOrigin.rotation.y, m_cameraOrigin.rotation.x);
var m_cameraMouseInput : Vector2 = Vector2.ZERO; 
const c_cameraMaxExtent = TAU * 0.25 * 0.9;
#
var m_chickkins : Array[Chickkin] = [];
var m_chickkinLeftGround : bool = false;

################################################################################

func getMovementInput() -> Vector2:
	return Vector2(
		Input.get_axis("player_move_right", "player_move_left"),
		Input.get_axis("player_move_backward", "player_move_forward")
	).rotated(m_cameraAngle.x);

var m_jumpInput : bool = false;
func getJumpInput() -> bool:
	return m_jumpInput
	
################################################################################

func _ready() -> void:
	#super();
	s_instance = self;

func _exit_tree() -> void:
	if (s_instance == self):
		s_instance = null;

var m_interactInput: bool = false;
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("player_move_jump")):
		m_jumpInput = true;
	if (Input.is_action_just_pressed("player_interact")):
		m_interactInput = true;
	
func _physics_process(delta: float) -> void:
	handleRoll(delta)
	handleCameraInput(delta);
	super(delta);
	handleChickkins(delta);
	handleAnimation(delta);
	handleInteract()
	
	m_jumpInput = false;
	m_interactInput = false;
	
################################################################################
# WARNING if there is more than one InteractComponent with intersecting areas, 
# the one entered first should win
var interactableComponents : Array[InteractComponent] = [];

func addInteractableArea(interactable : InteractComponent) -> void:
	interactableComponents.push_back(interactable)
	
func removeInteractableArea(interactable : InteractComponent) -> void:
	interactableComponents.erase(interactable)

func handleInteract() -> void:
	if !m_interactInput: return;
	if interactableComponents.size() <= 0: return;
	interactableComponents[0].interact();

################################################################################

func handleRoll(delta : float) -> void: 
	if (isGrounded()):
		m_ability_rollAvailable = m_ability_rollUnlocked;
		return;
	
	var input : Vector2 = getMovementInput();
	if (input.length_squared() <= 0): return;
	input = input.normalized();
	
	if (canJump() || !m_ability_rollAvailable || !getJumpInput()): return;
	m_momentum = input * m_ability_rollImpulse.x;
	m_gravityAmount = m_ability_rollImpulse.y;
	setAnimationVariableDirect("parameters/RollTrigger/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);
	m_ability_rollAvailable = false;

################################################################################

func handleAnimation(delta : float):
	var groundBlend : Vector2 = Vector2.ZERO;
	
	var input : Vector2 = getMovementInput();
	var flatVelocty : Vector2 = Vector2(velocity.x, velocity.z);
	if (flatVelocty.length_squared() > 0):
		var velocityAngle := flatVelocty.normalized().angle();
	
		var turn : float = -input.normalized().rotated(PI / 2).dot(flatVelocty.normalized());
		turn = sign(turn) * (1 - pow(1 - abs(turn), m_animationTurnExponent));
		
		groundBlend = Vector2(
			turn,
			min(flatVelocty.length() / m_groundMovementSpeed, 1.0)
		);
		if (groundBlend.length_squared() > 1.0):
			groundBlend = groundBlend.normalized();
		$Model.rotation.y = rotate_toward($Model.rotation.y, (PI / 2) - velocityAngle, TAU * m_animationTurnSpeed * delta);

	setAnimationVariable("parameters/Ground/blend_position", groundBlend, m_animationGroundBlendSpeed * delta);
	var airSpeed : float = sign(m_gravityAmount) * pow(clamp(abs(m_gravityAmount) / (m_groundJumpImpulse * m_animationJumpScaling), -1, 1), m_animationJumpExponent)
	setAnimationVariable("parameters/AirSpeed/blend_position", airSpeed, max(m_animationAirBlendSpeed, abs(airSpeed * 0.1)) * delta);
	setAnimationVariable("parameters/InAir/blend_amount", !isGrounded(), m_animationAirStateBlendSpeed * delta);
	
	var animationSpeed : float = max(1, (flatVelocty.length() * m_animationGroundSpeedScale) / getStateVariable("MovementSpeed"));
	if (m_animationTree.get("parameters/RollTrigger/active")): return;
	setAnimationPlaybackSpeed(animationSpeed, delta);

################################################################################

func _input(event):
	# Get mouse movement.
	if (event is InputEventMouseMotion && GameState.isMouseLocked()):
		m_cameraMouseInput += Vector2(
			event.relative.x,
			event.relative.y
		);

func handleCameraInput(delta : float):
	# Analog input.
	var cameraInput : Vector2 = Vector2(
		Input.get_axis("player_camera_left", "player_camera_right"),
		Input.get_axis("player_camera_up", "player_camera_down")
	) * GameSettings.camera_analogLookSensitivity;
	
	# Handle mouse input.
	if (GameState.isMouseLocked()):
		cameraInput += m_cameraMouseInput * GameSettings.camera_mouseLookSensitivity * 0.2;
		m_cameraMouseInput = Vector2.ZERO;

	# Vertical : horizontal ratio.
	cameraInput *= Vector2(1.0, 0.75);
		
	# Handle inversion.
	if (GameSettings.camera_invertCameraX): cameraInput.x *= -1;
	if (GameSettings.camera_invertCameraY): cameraInput.y *= -1;
	
	# Update camera angle.
	m_cameraAngle += cameraInput * delta;
	# Clamp camera angles.
	m_cameraAngle.y = clampf(m_cameraAngle.y, -c_cameraMaxExtent, c_cameraMaxExtent);
	#  Update camera rotation.
	m_cameraOrigin.rotation.y = -m_cameraAngle.x;
	m_cameraOrigin.rotation.x = m_cameraAngle.y;
	
################################################################################
	
func handleChickkins(delta : float) -> void:
	if (ChickkinPath.s_instance == null): return;
	
	if (isGrounded()):
		ChickkinPath.s_instance.updatePoint(global_position, m_chickkinLeftGround);
		m_chickkinLeftGround = false;
	else: 
		m_chickkinLeftGround = true;
	
	var pushback := ChickkinPath.s_instance.getPushBack();
	var prevDist : float = -INF;
	for chickkinIndex : int in range(m_chickkins.size()):
		var chickkin : Chickkin = m_chickkins[chickkinIndex];
		prevDist = chickkin.moveToPath(chickkinIndex, prevDist, pushback, delta);
		chickkin.updateVisuals(delta);
