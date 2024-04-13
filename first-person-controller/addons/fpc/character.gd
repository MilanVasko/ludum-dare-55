extends CharacterBody3D

# TODO: Add descriptions for each value

@export_category("Character")
@export var base_speed : float = 3.0
@export var sprint_speed : float = 6.0
@export var crouch_speed : float = 1.0

@export var acceleration : float = 10.0
@export var jump_velocity : float = 4.5
@export var mouse_sensitivity : float = 0.1
@export var _immobile : bool = false

var immobile: bool:
	get:
		return _immobile
	set(value):
		_immobile = value
		update_reticle(find_interactable_object())

@export_file var dot_reticle
@export_file var hand_reticle
@export_file var no_reticle

@export var initial_facing_direction : Vector3 = Vector3.ZERO

@export_group("Nodes")
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var HEADBOB_ANIMATION : AnimationPlayer
@export var JUMP_ANIMATION : AnimationPlayer
@export var CROUCH_ANIMATION : AnimationPlayer
@export var COLLISION_MESH : CollisionShape3D

@export_group("Controls")
# We are using UI controls because they are built into Godot Engine so they can be used right away
@export var JUMP : String = "ui_accept"
@export var LEFT : String = "ui_left"
@export var RIGHT : String = "ui_right"
@export var FORWARD : String = "ui_up"
@export var BACKWARD : String = "ui_down"
@export var CROUCH : String
@export var SPRINT : String

# Uncomment if you want full controller support
@export var LOOK_LEFT : String
@export var LOOK_RIGHT : String
@export var LOOK_UP : String
@export var LOOK_DOWN : String

@export_group("Feature Settings")
@export var jumping_enabled : bool = true
@export var in_air_momentum : bool = true
@export var motion_smoothing : bool = true
@export var sprint_enabled : bool = true
@export var crouch_enabled : bool = true
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
@export_enum("Hold to Sprint", "Toggle Sprint") var sprint_mode : int = 0
@export var dynamic_fov : bool = true
@export var continuous_jumping : bool = true
@export var view_bobbing : bool = true
@export var jump_animation : bool = true

@onready var hand_raycast: RayCast3D = $Head/Camera/RayCast3D

# Member variables
var speed : float = base_speed
var current_speed : float = 0.0
# States: normal, crouching, sprinting
var state : String = "normal"
var low_ceiling : bool = false # This is for when the cieling is too low and the player needs to crouch.
var was_on_floor : bool = true

var current_interactable_object: Node = null

var RETICLE : Control

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Set the camera rotation to whatever initial_facing_direction is
	if initial_facing_direction:
		HEAD.set_rotation_degrees(initial_facing_direction) # I don't want to be calling this function if the vector is zero

	change_reticle(dot_reticle)

	# Reset the camera position
	HEADBOB_ANIMATION.play("RESET")
	JUMP_ANIMATION.play("RESET")
	CROUCH_ANIMATION.play("RESET")


func change_reticle(reticle):
	if RETICLE:
		RETICLE.queue_free()

	RETICLE = load(reticle).instantiate()
	RETICLE.character = self
	$UserInterface.add_child(RETICLE)

func update_reticle(new_interactable_object: Node) -> void:
	if immobile:
		change_reticle(no_reticle)
	else:
		if new_interactable_object != null:
			change_reticle(hand_reticle)
		else:
			change_reticle(dot_reticle)

func update_reticle_if_necessary(new_interactable_object: Node):
	if new_interactable_object != current_interactable_object:
		current_interactable_object = new_interactable_object
		update_reticle(new_interactable_object)

func find_interactable_object() -> Node:
	var collider: Node = hand_raycast.get_collider()
	if collider == null:
		return null
	if collider.is_in_group("interactable") && collider.has_method("_interact"):
		return collider
	return null

func _physics_process(delta):
	var new_interactable_object := find_interactable_object()
	update_reticle_if_necessary(new_interactable_object)
	if new_interactable_object != null:
		if Input.is_action_just_pressed("interact"):
			new_interactable_object._interact()

	current_speed = Vector3.ZERO.distance_to(get_real_velocity())

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	handle_jumping()

	var input_dir = Vector2.ZERO
	if !immobile:
		input_dir = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	handle_movement(delta, input_dir)

	low_ceiling = $CrouchCeilingDetection.is_colliding()

	handle_state(input_dir)
	if dynamic_fov:
		update_camera_fov()

	if view_bobbing:
		headbob_animation(input_dir)

	if jump_animation:
		if !was_on_floor and is_on_floor(): # Just landed
			match randi() % 2:
				0:
					JUMP_ANIMATION.play("land_left")
				1:
					JUMP_ANIMATION.play("land_right")

		was_on_floor = is_on_floor() # This must always be at the end of physics_process


func handle_jumping():
	if jumping_enabled and !immobile:
		var is_jumping := Input.is_action_pressed(JUMP) if continuous_jumping else Input.is_action_just_pressed(JUMP)
		if is_jumping and is_on_floor() and !low_ceiling:
			if jump_animation:
				JUMP_ANIMATION.play("jump")
			velocity.y += jump_velocity


func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(-HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	move_and_slide()

	if in_air_momentum:
		if is_on_floor():
			if motion_smoothing:
				velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
				velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
			else:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
	else:
		if motion_smoothing:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed


func handle_state(moving):
	if sprint_enabled:
		if sprint_mode == 0:
			if Input.is_action_pressed(SPRINT) and state != "crouching":
				if moving:
					if state != "sprinting":
						enter_sprint_state()
				else:
					if state == "sprinting":
						enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
		elif sprint_mode == 1:
			if moving:
				# If the player is holding sprint before moving, handle that cenerio
				if Input.is_action_pressed(SPRINT) and state == "normal":
					enter_sprint_state()
				if Input.is_action_just_pressed(SPRINT):
					match state:
						"normal":
							enter_sprint_state()
						"sprinting":
							enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()

	if crouch_enabled:
		if crouch_mode == 0:
			if Input.is_action_pressed(CROUCH) and state != "sprinting":
				if state != "crouching":
					enter_crouch_state()
			elif state == "crouching" and !$CrouchCeilingDetection.is_colliding():
				enter_normal_state()
		elif crouch_mode == 1:
			if Input.is_action_just_pressed(CROUCH):
				match state:
					"normal":
						enter_crouch_state()
					"crouching":
						if !$CrouchCeilingDetection.is_colliding():
							enter_normal_state()


# Any enter state function should only be called once when you want to enter that state, not every frame.

func enter_normal_state():
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "normal"
	speed = base_speed

func enter_crouch_state():
	if immobile:
		return
	state = "crouching"
	speed = crouch_speed
	CROUCH_ANIMATION.play("crouch")

func enter_sprint_state():
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "sprinting"
	speed = sprint_speed


func update_camera_fov():
	if state == "sprinting":
		CAMERA.fov = lerp(CAMERA.fov, 85.0, 0.3)
	else:
		CAMERA.fov = lerp(CAMERA.fov, 75.0, 0.3)


func headbob_animation(moving):
	if moving and is_on_floor():
		var use_headbob_animation : String
		match state:
			"normal","crouching":
				use_headbob_animation = "walk"
			"sprinting":
				use_headbob_animation = "sprint"

		var was_playing : bool = false
		if HEADBOB_ANIMATION.current_animation == use_headbob_animation:
			was_playing = true

		HEADBOB_ANIMATION.play(use_headbob_animation, 0.25)
		HEADBOB_ANIMATION.speed_scale = (current_speed / base_speed) * 1.75
		if !was_playing:
			HEADBOB_ANIMATION.seek(float(randi() % 2)) # Randomize the initial headbob direction
			# Let me explain that piece of code because it looks like it does the opposite of what it actually does.
			# The headbob animation has two starting positions. One is at 0 and the other is at 1.
			# randi() % 2 returns either 0 or 1, and so the animation randomly starts at one of the starting positions.
			# This code is extremely performant but it makes no sense.

	else:
		HEADBOB_ANIMATION.play("RESET", 0.25)
		HEADBOB_ANIMATION.speed_scale = 1


func _process(_delta: float) -> void:
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	var controller_view_rotation = Input.get_vector(LOOK_LEFT, LOOK_RIGHT, LOOK_UP, LOOK_DOWN)
	HEAD.rotation_degrees.y -= controller_view_rotation.x * 1.5
	HEAD.rotation_degrees.x -= controller_view_rotation.y * 1.5


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and !immobile:
		HEAD.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		HEAD.rotation_degrees.x -= event.relative.y * mouse_sensitivity
