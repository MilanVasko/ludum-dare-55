extends CharacterBody3D

func _interact() -> void:
	Global.require_dialogue().play_dialogue_from_start("FishOMat")
