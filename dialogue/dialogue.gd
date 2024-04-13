extends Panel

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and Global.is_player_frozen():
		continue_dialogue()

func start_dialogue_mode() -> void:
	Global.freeze_player()
	visible = true

func end_dialogue_mode() -> void:
	Global.unfreeze_player()
	visible = false

func play_dialogue_from_start(dialogue_node: String) -> void:
	start_dialogue_mode()
	for child in get_children():
		if child.name == dialogue_node:
			var first := true
			for inner_child in child.get_children():
				inner_child.visible = first
				first = false
			child.visible = true
		else:
			child.visible = false

func continue_dialogue() -> void:
	for child in get_children():
		if !child.visible:
			continue
		var show_next := false
		for inner_child in child.get_children():
			if inner_child.visible:
				show_next = true
				inner_child.visible = false
				continue
			if show_next:
				show_next = false
				inner_child.visible = true
				return
		if show_next:
			# We got to the end of the dialogue
			end_dialogue_mode()
			return
	assert(false, "There is no active dialogue!")
