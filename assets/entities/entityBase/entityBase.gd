extends CharacterBody3D
class_name EntityBase;

################################################################################
# Overwrite Me!

func getMovementInput() -> Vector2:
	return Vector2.ZERO;
func getJumpInput() -> bool:
	return false;

################################################################################

# Movement
@export_group("Movement Config", "m_movement")
@export var m_movementTurnVelocityMinimum : float = 0.4;
# Ground
@export_group("Ground Config", "m_ground")
@export var m_groundMovementSpeed : float = 8;
@export var m_groundTurnSpeed : float = 1;
@export var m_groundMomentumSpeed : float = 12;
# Air
@export_group("Air Config", "m_air")
@export var m_airMovementSpeed : float = 7;
@export var m_airTurnSpeed : float = 0.2;
@export var m_airMomentumSpeed : float = 5;
# Gravity
@export_group("Gravity Config", "m_gravity")
@export var m_gravityAcceleration : float = -9.8;
var m_gravityAmount : float = 0;
@export var m_gravityFallingMultiplier : float = 2.0;
@export var m_gravityJumpImpulse : float = 8.0;
#
@onready var m_animationTree : AnimationTree = $AnimationTree;
@onready var m_currentMovementAngle : float = rotation.y;
var m_momentum : Vector2 = Vector2.ZERO;
var m_targetVelocity : Vector3 = Vector3.ZERO;
	
################################################################################

func _physics_process(delta: float) -> void:
	m_targetVelocity = Vector3.ZERO;

	var movement : Vector2 = getTargetMovement(delta);
	
	m_targetVelocity.x = movement.x;
	m_targetVelocity.y = getTargetGravity(delta);
	m_targetVelocity.z = movement.y;
	
	m_momentum = m_momentum.move_toward(Vector2(m_targetVelocity.x, m_targetVelocity.z), getStateVariable("MomentumSpeed") * delta);
	m_targetVelocity.x = m_momentum.x;
	m_targetVelocity.z = m_momentum.y;

	velocity = m_targetVelocity;
	move_and_slide();

################################################################################

func getTargetMovement(delta) -> Vector2:
	var input = getMovementInput().normalized();
	if (input.length_squared() <= 0): return Vector2.ZERO;
	#
	var targetAngle : float = input.angle();
	#
	m_currentMovementAngle = rotate_toward(m_currentMovementAngle, targetAngle, TAU * getStateVariable("TurnSpeed") * delta);
	var movementVector : Vector2 = Vector2.from_angle(m_currentMovementAngle)
	var movementMultiplier : float = max(m_movementTurnVelocityMinimum, remap(input.dot(movementVector), 0.0, 1.0, m_movementTurnVelocityMinimum, 1.0));
	#
	return movementVector * movementMultiplier * getStateVariable("MovementSpeed");

func getTargetGravity(delta) -> float:
	var gravityAcceleration : float = 0;
	#
	if (isGrounded()):
		if (!getJumpInput()):
			m_gravityAmount = 0.05 * sign(m_gravityAcceleration);
		else: 
			m_gravityAmount = m_gravityJumpImpulse;
		return m_gravityAmount;
	elif (m_gravityAmount < 0):
		gravityAcceleration = m_gravityAcceleration * m_gravityFallingMultiplier;
	else:
		gravityAcceleration = m_gravityAcceleration;
	#	
	gravityAcceleration *= 0.5 * delta;
	#
	m_gravityAmount += gravityAcceleration;
	var gravity = m_gravityAmount;
	m_gravityAmount += gravityAcceleration;
	#
	return gravity;

################################################################################

func getStateVariable(propertyName : String) -> Variant:
	var prefix : String = "m_ground" if (isGrounded()) else "m_air";
	return get(prefix + propertyName);

func isGrounded() -> bool:
	return is_on_floor() && (m_gravityAmount * sign(m_gravityAcceleration) > 0.0);

################################################################################

func setAnimationPlaybackSpeed(speed : float, delta : float) -> void:
	m_animationTree.advance((speed - 1) * delta);

func setAnimationVariable(propertyName : StringName, value : Variant, adjustmentSpeed : float) -> void:
	var currentValue = m_animationTree.get(propertyName);
	match (typeof(value)):
		TYPE_VECTOR2:
			currentValue = currentValue.move_toward(value, adjustmentSpeed);
		_: 
			currentValue = move_toward(currentValue, value, adjustmentSpeed);
	m_animationTree.set(propertyName, currentValue);
