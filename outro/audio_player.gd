extends AudioStreamPlayer

@export var human_sounds: Array[AudioStream]
@export var demon_sounds: Array[AudioStream]

func _on_outro_dialogue_text_appeared(_dialogue_name: String, dialogue_sound: DialogueText.DialogueSound) -> void:
	if playing:
		stop()
	if dialogue_sound == DialogueText.DialogueSound.DEMON3:
		stream = demon_sounds.pick_random()
		play()
	elif dialogue_sound == DialogueText.DialogueSound.HUMAN:
		stream = human_sounds.pick_random()
		play()
