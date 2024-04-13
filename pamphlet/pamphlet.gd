extends StaticBody3D

func _interact() -> void:
	Global.require_dialogue().play_dialogue_from_start("Pamphlet")
