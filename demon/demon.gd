extends CharacterBody3D

@export var dialogue_sound: DialogueText.DialogueSound
var first_interaction := true
@export var sound_clips: Array[AudioStream]
@onready var audio_player := $AudioStreamPlayer3D

func _interact() -> void:
	Global.require_dialogue().play_dialogue_from_start("Demon" if first_interaction else "DemonAgain")
	first_interaction = false

func _on_dialogue_text_appeared(_dialogue_name: String, current_dialogue_sound: DialogueText.DialogueSound) -> void:
	if audio_player.playing:
		audio_player.stop()
	if current_dialogue_sound == dialogue_sound || current_dialogue_sound == DialogueText.DialogueSound.DEMONS:
		audio_player.stream = sound_clips.pick_random()
		audio_player.play()
