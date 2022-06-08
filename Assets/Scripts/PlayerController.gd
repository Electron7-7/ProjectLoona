extends KinematicBody

#### VARIABLES ####
var mouse_sensitivity = 0.06
var gravity = 37
var jump = 15
var speed = 15
var acceleration = 8
var vertical_acceleration = 1
var horizontal_acceleration = 8

var isGrounded = false
var direction = Vector3()
var veloH = Vector3()
var movement = Vector3()
var gravityVector = Vector3()

onready var head = $Head
onready var ground_check = $_GroundCheck
#### VARIABLES ####

#### FUNCTIONS ####
func PlayerMovement(delta):
	direction = Vector3()

	if ground_check.is_colliding():
		isGrounded = true
	else:
		isGrounded = false

	if not is_on_floor():
		gravityVector += Vector3.DOWN * gravity * delta
		horizontal_acceleration = vertical_acceleration
	elif is_on_floor() and isGrounded:
		gravityVector = -get_floor_normal() * gravity
		horizontal_acceleration = acceleration
	else:
		gravityVector = -get_floor_normal()
		horizontal_acceleration = acceleration


	if Input.is_action_just_pressed("Jump") and ( is_on_floor() or ground_check.is_colliding() ):
		gravityVector = Vector3.UP * jump

	if Input.is_action_pressed("moveForward"):
		direction -= transform.basis[2]
	if Input.is_action_pressed("moveBack"):
		direction += transform.basis[2]
	if Input.is_action_pressed("moveLeft"):
		direction -= transform.basis[0]
	if Input.is_action_pressed("moveRight"):
		direction += transform.basis[0]

	veloH = veloH.linear_interpolate(direction.normalized() * speed, horizontal_acceleration * delta)

	movement[0] = veloH[0] + gravityVector[0]
	movement[1] = gravityVector[1]
	movement[2] = veloH[2] + gravityVector[2]

	move_and_slide(movement, Vector3.UP) # warning-ignore:return_value_discarded
#### FUNCTIONS ####

func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative[0] * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative[1] * mouse_sensitivity))
		head.rotation[0] = clamp(head.rotation[0], deg2rad(-89), deg2rad(89))

	if event.is_action_pressed("Fire"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	elif event.is_action_pressed("AltFire"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		PlayerMovement(delta)
