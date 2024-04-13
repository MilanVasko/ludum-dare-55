extends StaticBody3D

@export var plant_scene: PackedScene
@onready var cat := $Cat
@onready var animation_player := $AnimationPlayer

func _ready() -> void:
	cat.visible = false

func _can_interact() -> bool:
	return Global.require_inventory().has_plant()

func _interact() -> void:
	Global.require_inventory().remove_plant()
	var plant := plant_scene.instantiate()
	plant.remove_from_group("interactable")
	animation_player.play("cat-appear")
	add_child(plant)

func _on_animation_finished(_anim_name) -> void:
	animation_player.play("cat-idle")
