extends Control

@onready var plant := $VBoxContainer/Plant
@onready var coin := $VBoxContainer/Coin
@onready var fish := $VBoxContainer/Fish
@onready var audio_player := $AudioStreamPlayer

func _ready() -> void:
	plant.visible = false
	coin.visible = false
	fish.visible = false

func add_plant() -> void:
	plant.visible = true
	audio_player.play()

func remove_plant() -> void:
	plant.visible = false

func has_plant() -> bool:
	return plant.visible

func add_coin() -> void:
	coin.visible = true
	audio_player.play()

func remove_coin() -> void:
	coin.visible = false

func has_coin() -> bool:
	return coin.visible

func add_fish() -> void:
	fish.visible = true
	audio_player.play()

func remove_fish() -> void:
	fish.visible = false

func has_fish() -> bool:
	return fish.visible
