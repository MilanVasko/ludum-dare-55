extends CharacterBody3D

func _interact() -> void:
	var inventory := Global.require_inventory()
	if inventory.has_coin():
		inventory.remove_coin()
		Global.require_dialogue().play_dialogue_from_start("Fish")
		inventory.add_fish()
	else:
		Global.require_dialogue().play_dialogue_from_start("FishOMat")
