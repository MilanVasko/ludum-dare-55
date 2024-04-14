extends Control

signal dialogue_started(dialogue_name: String)
signal dialogue_text_appeared(dialogue_name: String, dialogue_sound: DialogueText.DialogueSound)
signal dialogue_ended(dialogue_name: String)

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if !visible:
		return
	get_viewport().set_input_as_handled()
	if event.is_action_pressed("interact"):
		continue_dialogue()

func start_dialogue(dialogue_name: String) -> void:
	visible = true
	dialogue_started.emit(dialogue_name)

func end_dialogue(dialogue_name: String) -> void:
	visible = false
	dialogue_ended.emit(dialogue_name)

func play_dialogue_from_start(dialogue_name: String) -> void:
	start_dialogue(dialogue_name)
	var found := false
	for child in get_children():
		if child.name == dialogue_name:
			found = true
			var first := true
			for inner_child in child.get_children():
				inner_child.visible = first
				if first:
					dialogue_text_appeared.emit(dialogue_name, inner_child.dialogue_sound)
				first = false
			child.visible = true
		else:
			child.visible = false
	assert(found, "Dialogue \"" + dialogue_name + "\" not found")

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
				dialogue_text_appeared.emit(child.name, inner_child.dialogue_sound)
				return
		if show_next:
			# We got to the end of the dialogue
			call_deferred("end_dialogue", child.name)
			return
	assert(false, "There is no active dialogue!")
