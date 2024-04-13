extends Node

const DEMONS_ARRIVING_ANIMATION = "demons-arriving"
const DEMONS_ARRIVED_DIALOGUE = "DemonsArrived"
const DEMONS_SUMMONING_ANIMATION = "demons-summoning"
const DEMONS_SUMMONING_DIALOGUE = "DemonsSummoning"
const SUMMONING_FADEOUT_ANIMATION = "summoning-fadeout"
const SPAWN_FADEIN_ANIMATION = "spawn-fadein"
const JUST_SUMMONED_DIALOGUE = "JustSummoned"
const DEMON_DIALOGUE = "Demon"

@onready var animation_player = $AnimationPlayer
@export var player_scene: PackedScene
@export var player_spawn_point: NodePath
@export var main_scene: NodePath

func _ready() -> void:
	animation_player.play(DEMONS_ARRIVING_ANIMATION)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_cutscene"):
		if animation_player.is_playing():
			skip_animation()
			get_viewport().set_input_as_handled()

func skip_animation() -> void:
	animation_player.advance(INF)

func _on_dialogue_ended(dialogue_name: String) -> void:
	if dialogue_name == DEMONS_ARRIVED_DIALOGUE:
		animation_player.play(DEMONS_SUMMONING_ANIMATION)
	elif dialogue_name == DEMONS_SUMMONING_DIALOGUE:
		animation_player.play(SUMMONING_FADEOUT_ANIMATION)
	elif dialogue_name == JUST_SUMMONED_DIALOGUE:
		# TODO: animation of demons running away
		queue_free()
	else:
		assert(false, "Unhandled dialogue name \"" + dialogue_name + "\"")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == DEMONS_ARRIVING_ANIMATION:
		Global.require_dialogue().play_dialogue_from_start(DEMONS_ARRIVED_DIALOGUE)
	elif anim_name == DEMONS_SUMMONING_ANIMATION:
		Global.require_dialogue().play_dialogue_from_start(DEMONS_SUMMONING_DIALOGUE)
	elif anim_name == SUMMONING_FADEOUT_ANIMATION:
		$IntroCamera.queue_free()
		spawn_player()
	elif anim_name == SPAWN_FADEIN_ANIMATION:
		Global.require_dialogue().play_dialogue_from_start(JUST_SUMMONED_DIALOGUE)
	else:
		assert(false, "Unhandled animation name \"" + anim_name + "\"")

func spawn_player() -> void:
	print("Spawn player start")
	var player_instance: Node3D = player_scene.instantiate()
	get_node(main_scene).add_child(player_instance)
	player_instance.immobile = true
	var spawn_point: Node3D = get_node(player_spawn_point)
	player_instance.global_position = spawn_point.global_position
	animation_player.play(SPAWN_FADEIN_ANIMATION)
