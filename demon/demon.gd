extends CharacterBody3D

func _interact() -> void:
	Global.require_dialogue().play_dialogue_from_start("Demon")
	remove_from_group("interactable")
