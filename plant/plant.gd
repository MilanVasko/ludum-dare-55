extends StaticBody3D

func _interact() -> void:
	Global.require_player().pick_up_plant()
	queue_free()
