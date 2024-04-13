extends StaticBody3D

@onready var cat := $Cat
@onready var plant := $Plant
@onready var fish := $Fish
@onready var animation_player := $AnimationPlayer

func _ready() -> void:
	cat.visible = false
	plant.visible = false
	fish.visible = false
	plant.remove_from_group("interactable")

func _can_interact() -> bool:
	var inventory := Global.require_inventory()
	if !plant.visible:
		return inventory.has_plant()
	return !fish.visible && inventory.has_fish()

func _interact() -> void:
	var inventory := Global.require_inventory()
	if !plant.visible:
		plant.visible = true
		inventory.remove_plant()
		animation_player.play("cat-appear")
		return
	if !fish.visible:
		fish.visible = true
		inventory.remove_fish()

func _on_animation_finished(_anim_name) -> void:
	animation_player.play("cat-idle")
