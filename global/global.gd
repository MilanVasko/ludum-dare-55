extends Node

func toggle_freeze_player() -> void:
	if is_player_unfrozen():
		freeze_player()
	elif is_player_frozen():
		unfreeze_player()
	else:
		assert(false, "Invalid freeze state")

func freeze_player() -> void:
	var player := require_player()
	player.immobile = true

func unfreeze_player() -> void:
	var player := require_player()
	player.immobile = false

func is_player_frozen() -> bool:
	return require_player().immobile

func is_player_unfrozen() -> bool:
	return !require_player().immobile

func require_player() -> Node:
	var player := find_player_or_null()
	assert(player != null, "Player not found")
	return player

func find_player_or_null() -> Node:
	return get_tree().get_first_node_in_group("player")

func require_dialogue() -> Node:
	var dialogue := find_dialogue_or_null()
	assert(dialogue != null, "Dialogue not found")
	return dialogue

func find_dialogue_or_null() -> Node:
	return get_tree().get_first_node_in_group("dialogue")

func require_inventory() -> Node:
	var inventory := find_inventory_or_null()
	assert(inventory != null, "Inventory not found")
	return inventory

func find_inventory_or_null() -> Node:
	return get_tree().get_first_node_in_group("inventory")
