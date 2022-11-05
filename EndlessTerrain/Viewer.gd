extends Marker3D
@export var ball_scene :PackedScene
@export var speed = 250
var mouse_input = Vector2()
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	position+= global_transform.basis.x * input.x * speed * delta
	position+= global_transform.basis.z *input.y * speed * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		var b = ball_scene.instantiate() as RigidBody3D
		get_parent().add_child(b)
		b.global_position = global_position
		b.apply_central_impulse(Vector3.FORWARD * 100)
		
		
	rotation.y -= mouse_input.x * 6 * delta
	
	mouse_input = Vector2()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_input = event.relative
