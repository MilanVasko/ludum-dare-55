extends Node3D

@export var fish_place_path: NodePath
@onready var fish_place: Node = get_node(fish_place_path)
var first_interaction := true

func _ready() -> void:
	Global.require_dialogue().dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended(dialogue_name: String) -> void:
	if dialogue_name == "CatSuccess":
		var animation_player := get_node("/root/Main/CanvasLayer/AnimationPlayer")
		animation_player.play("fade-out")
		animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "fade-out":
		if is_inside_tree():
			var err := get_tree().change_scene_to_file("res://outro/outro.tscn")
			assert(err == OK)

func _interact() -> void:
	var dialogue := Global.require_dialogue()
	if first_interaction:
		first_interaction = false
		dialogue.play_dialogue_from_start("Cat")
	else:
		if Global.require_inventory().has_fish() or fish_place.visible:
			dialogue.play_dialogue_from_start("CatSuccess")
		else:
			dialogue.play_dialogue_from_start("CatAgain")
