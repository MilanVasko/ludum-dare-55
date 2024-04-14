extends StaticBody3D

@export var dialogue_name: String

func _can_interact() -> bool:
	return dialogue_name != ""

func _interact() -> void:
	Global.require_dialogue().play_dialogue_from_start(dialogue_name)
