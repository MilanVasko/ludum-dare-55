extends CharacterBody3D

func _interact() -> void:
	Global.require_inventory().add_coin()
	queue_free()
