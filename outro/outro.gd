extends "res://dialogue/dialogue.gd"

func _ready():
	super._ready()
	play_dialogue_from_start("Outro")


func _on_dialogue_ended(dialogue_name: String) -> void:
	if dialogue_name == "Outro":
		var err := get_tree().change_scene_to_file("res://pre-intro/pre-intro.tscn")
		assert(err == OK)
