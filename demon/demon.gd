extends CharacterBody3D

var first_interaction := true

func _interact() -> void:
	Global.require_dialogue().play_dialogue_from_start("Demon" if first_interaction else "DemonAgain")
	first_interaction = false
