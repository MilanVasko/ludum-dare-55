extends CharacterBody3D

func _interact() -> void:
	print("Hello")
	remove_from_group("interactable")
