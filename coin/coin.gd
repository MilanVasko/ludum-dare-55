extends CharacterBody3D

func _interact() -> void:
	Global.require_dialogue().play_dialogue_from_start("Coin")
	Global.require_inventory().add_coin()
	queue_free()
