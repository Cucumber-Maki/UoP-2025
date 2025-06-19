extends Node


func _ready() -> void:
	GameSettings.bindValueChanged("volume_master", updateMaster)
	GameSettings.bindValueChanged("volume_effect", updateEffects)
	GameSettings.bindValueChanged("volume_music", updateMusic)
	
func updateMaster() -> void:
	updateMusic();
	updateEffects();

func updateEffects() -> void:
	updateGroup("AudioEffect", GameSettings.volume_master*GameSettings.volume_effect);

func updateMusic() -> void:
	updateGroup("AudioMusic", GameSettings.volume_master*GameSettings.volume_music);

func updateGroup(group : StringName, volume : float) -> void:
	print(volume)
	var nodes := get_tree().get_nodes_in_group(group)
	print(nodes)
	for node in nodes:
		var asp = node as AudioStreamPlayer
		if asp == null:
			asp = node as AudioStreamPlayer3D
			print("Node is Audio3D")
		
		if asp != null:
			asp.volume_db = linear_to_db(volume)
			print("Volume set")
		
