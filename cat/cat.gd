extends Node3D

var first_interaction := true

func _interact() -> void:
	Global.require_dialogue().play_dialogue_from_start("Cat" if first_interaction else "CatAgain")
	first_interaction = false
