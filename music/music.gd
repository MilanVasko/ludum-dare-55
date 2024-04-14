extends AudioStreamPlayer

@export var music_clips: Array[AudioStream]
var current_clip := 0

func _ready() -> void:
	play_next()

func _on_finished() -> void:
	play_next()

func play_next() -> void:
	stream = music_clips[current_clip]
	current_clip = (current_clip + 1) % music_clips.size()
	play()
