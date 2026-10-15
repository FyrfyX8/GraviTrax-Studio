extends CharacterBody3D

@export var player_speed : float = 1
@export var mouse_sensitivity : float = 0.005

@export_enum("Perspective", "Isometric") var camera_mode : int = 0:
	set(val):
		camera_mode = val
		if val == 0:
			IsometricCamera.current = false
			IsometricCamera.process_mode = Node.PROCESS_MODE_DISABLED
			PerspectiveCamera.process_mode = Node.PROCESS_MODE_ALWAYS
			PerspectiveCamera.current = true
			current_camera = PerspectiveCamera
		elif val == 1:
			PerspectiveCamera.current = false
			PerspectiveCamera.process_mode = Node.PROCESS_MODE_DISABLED
			IsometricCamera.process_mode = Node.PROCESS_MODE_ALWAYS
			IsometricCamera.current = true
			current_camera = IsometricCamera
		else:
			push_warning("camera_mode has been set to invalid mode")

@export var CameraPosition : Marker3D

@export var PerspectiveCamera : Camera3D # Camera used for Perspective view
@export var IsometricCamera : Camera3D # Camera used for Isometric view
var current_camera : Camera3D

const DEFAULT_ISO_DISTANCE : float = 10

var rotating_view : bool = false
var camera_zoom : float = 10 # this changes the distance of CameraPos in Perspective mode and the Size of IsometricCamera 
@onready var viewport_rect : Rect2 = get_viewport().get_visible_rect() # needed for wrapping the cursor in the view while rotating the camera

var target_velocity = Vector3.ZERO

func _ready():
	camera_mode = camera_mode

func _input(event):
	if event is InputEventMouseMotion and rotating_view:
		rotation.y += -event.relative.x * mouse_sensitivity
		rotation.x += -event.relative.y * mouse_sensitivity
		

func _process(delta):
	if Input.is_action_pressed("mouse_scroll_up"):
		return # Zoom
	if Input.is_action_just_pressed("mouse_right"):
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		rotating_view = true
	if Input.is_action_just_released("mouse_right"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		rotating_view = false

func _physics_process(delta):
	var direction = Vector3.ZERO
	var input_dir = Vector2.ZERO
	
	# get player directional inputs
	input_dir = Input.get_vector("player_left","player_right","player_forward","player_backward")
	print(input_dir)
	direction = Vector3(input_dir.x, 0, input_dir.y).rotated(transform.basis.y, rotation.y).normalized()
		
	target_velocity.x = direction.x * player_speed * camera_zoom
	target_velocity.z = direction.z * player_speed * camera_zoom
	
	velocity = target_velocity
	move_and_slide()
