extends CharacterBody3D
@export var ball_scene :PackedScene
@export var speed = 20
var mouse_input = Vector2()
var move_vector = Vector3()
@export var gravity_enabled = false 
var gravity = 8.81
var gravity_vector = Vector3()
@onready var cam = $Cam
@onready var cam_v = $Cam/V
const BIRDS_EYE = Vector3(0,2000,0)
const NORMAL_VIEW = Vector3(0,1,4)
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_vector = Vector3()
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			cam_v.get_child(0).position = BIRDS_EYE
			cam_v.get_child(0).rotation = Vector3(-PI/2,0,0)
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			cam_v.get_child(0).position = NORMAL_VIEW
			cam_v.get_child(0).rotation = Vector3(0,0,0)
			
	var input = Input.get_vector("left","right","up","down")
	move_vector += cam.global_transform.basis.x * input.x * speed
	move_vector += cam.global_transform.basis.z * input.y * speed
	
#	if Input.is_action_just_pressed("ui_accept"):
#		var b = ball_scene.instantiate() as RigidBody3D
#		get_parent().add_child(b)
#		b.global_position = global_position
#		b.apply_central_impulse(Vector3.FORWARD * 100)
#
		
	cam.rotation.y -= mouse_input.x * delta
	cam_v.rotation.x -= mouse_input.y * delta
	cam_v.rotation.x = clamp(cam_v.rotation.x, deg_to_rad(-50),deg_to_rad(40))
	if is_on_floor():
		gravity_vector.y = 0
	else:
		if gravity_enabled:
			gravity_vector.y -=  18.81 * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		gravity_vector.y = 30
	
	velocity = move_vector + gravity_vector
	var col = move_and_slide()
	print(col)
	mouse_input = Vector2()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_input = event.relative
