class_name Player3D extends CharacterBody3D

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var head = $Head
@onready var debug = $DebugText

## Change the way sprinting works.[br]
##[param SOURCE_2] only lets the player start or stop sprinting while on the ground.[br]
##[param I_HAVE_JET_BOOTS] allows the player to start and stop their sprint both in the air and on the ground.
enum SPRINT_TYPE {SOURCE_2, I_HAVE_JET_BOOTS}
@export var Sprint_Type: SPRINT_TYPE

## Set the mouse sensitivity from the inspector
@export_range(0, 100, 1) var mouse_sensitivity: float = 8

## The values for walking and sprinting speed.
enum SPEED {WALKING = 3, SPRINTING = 6}

var movement_velocity: Vector3
var sprint_velocity: Vector3
var gravity_velocity: Vector3
var jump_velocity: Vector3
var look_direction: Vector2

var jumping: bool = false
var sprinting: bool = false

var speed: float
var acceleration: float = 25
var jump_height: float = 1


#### System Functions
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_direction = event.relative * 0.01
	jumping = Input.is_action_just_pressed('jump')


func _physics_process(delta: float) -> void:
	velocity = _move(delta) + _gravity(delta) + _jump(delta)
	move_and_slide()
	_debug([speed])


func _process(delta: float) -> void:
	_rotate_camera(delta)


#### Custom Functions
func _debug(display_args: Array) -> void:
	var display_string: String = ''
	for item in display_args:
		display_string += str(item) + '\n'
	debug.text = display_string


func _gravity(delta: float) -> Vector3:
	gravity_velocity = Vector3.ZERO if is_on_floor() else gravity_velocity.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return gravity_velocity


func _rotate_camera(delta: float, sensitivity_modifier: float = 1.0) -> void:
	var turn_speed = look_direction * mouse_sensitivity * sensitivity_modifier * delta

	head.rotation.y -= turn_speed.x
	head.rotation.x = clamp(head.rotation.x - turn_speed.y, -1.5, 1.5)
	
	look_direction = Vector2.ZERO


func _move(delta: float) -> Vector3:
	var movement_vector := Input.get_vector('move_left', 'move_right', 'move_forward', 'move_backward')
	var _forward: Vector3 = head.transform.basis * Vector3(movement_vector.x, 0, movement_vector.y)
	var walk_direction := Vector3(_forward.x, 0, _forward.z).normalized()

	match Sprint_Type:
		0:
			if is_on_floor() and not Input.is_action_just_pressed('sprint'):
				sprinting = Input.is_action_pressed('sprint')
		1:
			sprinting = Input.is_action_pressed('sprint')

	speed = SPEED.SPRINTING if sprinting else SPEED.WALKING

	movement_velocity = movement_velocity.move_toward(walk_direction * speed * walk_direction.length(), acceleration * delta)

	return movement_velocity


func _jump(delta: float) -> Vector3:
	if is_on_floor():
		if jumping:
			jump_velocity = Vector3(0, sqrt(jump_height * gravity), 0)
			jumping = false
			return jump_velocity
		else:
			jump_velocity = Vector3.ZERO
	else:
		jump_velocity.move_toward(Vector3.ZERO, gravity * delta)
	
	return jump_velocity

