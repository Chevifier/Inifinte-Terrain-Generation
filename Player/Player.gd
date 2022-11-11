extends CharacterBody3D

@onready var cam = $Cam
@onready var cam_v = $Cam/V

@onready var bird_cam = $Cam2
@onready var normal_cam = $Cam/V/Cam1
@export var JUMP_VELOCITY = 6.5
@export var SPEED = 20
var mouse_input = Vector2()
var move_vector = Vector3()
@export var gravity_enabled = false 
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.86

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	
	if Input.is_action_just_pressed("gravity_toggle"):
		gravity_enabled = !gravity_enabled
	# Add the gravity.
	if not is_on_floor() and gravity_enabled:
		velocity.y -= gravity * delta
		
	var vertical_move = Input.get_axis("crouch","jump")
	if gravity_enabled==false:
		velocity.y = vertical_move * SPEED

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (cam.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	#Camera Control
	cam.rotation.y -= mouse_input.x * delta
	cam_v.rotation.x -= mouse_input.y * delta
	cam_v.rotation.x = clamp(cam_v.rotation.x, deg_to_rad(-50),deg_to_rad(40))
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("camera_toggle"):
		if bird_cam.current == true:
			normal_cam.current = true
		else:
			bird_cam.current = true
	mouse_input = Vector2()
	
	

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			mouse_input = event.relative
	else:
		cam.rotation = Vector3()


func _on_player_speed_value_changed(value):
	SPEED = value
