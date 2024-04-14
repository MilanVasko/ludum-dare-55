extends CharacterBody3D

@onready var audio_player := $AudioStreamPlayer3D

func _interact() -> void:
	var inventory := Global.require_inventory()
	if inventory.has_coin():
		if audio_player.playing:
			audio_player.stop()
		inventory.remove_coin()
		Global.require_dialogue().play_dialogue_from_start("Fish")
		audio_player.play()
		inventory.add_fish()
	else:
		Global.require_dialogue().play_dialogue_from_start("FishOMat")
