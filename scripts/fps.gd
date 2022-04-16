extends KinematicBody

var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 5

var capture_mouse = false
var move_allowed = true
var look_held = false

var cam_accel = 40
var mouse_sense = 0.1
var snap

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

onready var head = $Head
onready var camera = $Head/Camera
onready var root_scene = get_root_scene()

func get_root_scene():
	for i in get_tree().root.get_children():
		if i is BaseScene: return i
	push_error("[FPS] Root scene was not found")

func disallow_move(): self.move_allowed = false
func allow_move(): self.move_allowed = true

func is_in_look_mode(): return self.capture_mouse || self.look_held
func is_in_cursor_mode(): return !self.capture_mouse && !self.look_held

func toggle_capture_mouse():
	if (self.capture_mouse):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		root_scene.enable_cursor()
		self.capture_mouse = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		root_scene.disable_cursor()
		self.capture_mouse = true

func _input(event):
	if (!self.move_allowed): return
	
	if (self.capture_mouse || self.look_held):
		# get mouse input for camera rotation
		if event is InputEventMouseMotion:
			rotate_y(deg2rad(-event.relative.x * mouse_sense))
			head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
			head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _process(delta):
	if (!self.move_allowed): return
	
	if Input.is_action_just_pressed("toggle_cursor"):
		self.toggle_capture_mouse()
	
	if (self.capture_mouse || self.look_held):
		# camera physics interpolation to reduce physics jitter on high refresh-rate monitors
		if Engine.get_frames_per_second() > Engine.iterations_per_second:
			camera.set_as_toplevel(true)
			camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
			camera.rotation.y = rotation.y
			camera.rotation.x = head.rotation.x
		else:
			camera.set_as_toplevel(false)
			camera.global_transform = head.global_transform
		
func _physics_process(delta):
	if (self.move_allowed):
		# get keyboard input
		direction = Vector3.ZERO
		var h_rot = global_transform.basis.get_euler().y
		var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
		
		# get mouse input
		self.look_held = Input.is_action_pressed("hold_look")
	else:
		direction = Vector3(0, 0, 0)
	
	# jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
	
	# make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)
