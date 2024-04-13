extends CharacterBody3D

func _interact() -> void:
	Global.require_dialogue().play_dialogue_from_start("FishOMat")
	var inventory := Global.require_inventory()
	if inventory.has_coin():
		inventory.remove_coin()
		inventory.add_fish()
