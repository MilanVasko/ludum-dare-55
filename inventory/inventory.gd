extends Control

@onready var plant := $Plant

func _ready() -> void:
	plant.visible = false

func add_plant() -> void:
	plant.visible = true

func remove_plant() -> void:
	plant.visible = false

func has_plant() -> bool:
	return plant.visible
