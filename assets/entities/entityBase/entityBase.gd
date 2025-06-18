extends CharacterBody3D
class_name EntityBase;

################################################################################

@onready var m_animationTree : AnimationTree = $AnimationTree;	
	
################################################################################

func setAnimationPlaybackSpeed(speed : float, delta : float) -> void:
	m_animationTree.advance((speed - 1) * delta);

func setAnimationVariableDirect(propertyName : StringName, value : Variant) -> void:
	m_animationTree.set(propertyName, value);
	
func setAnimationVariable(propertyName : StringName, value : Variant, adjustmentSpeed : float) -> void:
	var currentValue = m_animationTree.get(propertyName);
	match (typeof(value)):
		TYPE_VECTOR2:
			currentValue = currentValue.move_toward(value, adjustmentSpeed);
		_: 
			currentValue = move_toward(currentValue, value, adjustmentSpeed);
	m_animationTree.set(propertyName, currentValue);
