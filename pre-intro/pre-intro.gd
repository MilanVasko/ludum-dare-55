extends Control

func _ready() -> void:
	$AnimationPlayer.play("pre-intro")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_cutscene"):
		end()

func end() -> void:
	var err := get_tree().change_scene_to_file("res://main.tscn")
	assert(err == OK)

func _on_animation_player_animation_finished(_anim_name: String) -> void:
	end()
