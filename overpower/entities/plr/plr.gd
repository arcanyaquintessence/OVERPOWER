extends CharacterBody3D
class_name Player

@onready var model: Node3D = %Model
@onready var head: Node3D = %Head
@onready var camera: Camera3D = %Camera3D
@onready var camera_spring: SpringArm3D = $Head/CameraSpring
@onready var nametag: Label3D = %Nametag

@export_category("Ground Movement")
@export var base_speed:float = 7.0
@export var ground_accel:float = 14.0
@export var ground_deccel:float = 10.0
@export var ground_friction:float = 6.0

@export_category("Jumping")
@export var jump_velocity:float = 6.0
@export var auto_jump:bool = true

@export_category("Air Movement")
@export var air_cap:float = 0.85
@export var air_accel:float = 800.0
@export var air_speed:float = 500.0

@export_category("Camera")
@export var base_fov:float = 75
@export_range(0, 179, .5) var min_fov:float = 75
@export_range(0, 179, .5) var max_fov:float = 150
@export var look_sensitivity:float = 0.005
@export var min_vertical_look_direction:int = -75
@export var max_vertical_look_direction:int = 75
@export var min_zoom:float=0
@export var max_zoom:float=5
@export var HEADBOB_STRENGTH:float = 0.05
@export var HEADBOB_FREQUENCY:float = 2.4
var headbob_time:float = 0.0

var can_move:bool = true
var wish_dir:Vector3 = Vector3.ZERO

func _ready() -> void:
	nametag.text = "Player_"+name
	
func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif e.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if e is InputEventMouseMotion:
			rotate_y(-e.relative.x * look_sensitivity)
			head.rotate_x(-e.relative.y * look_sensitivity)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(min_vertical_look_direction), deg_to_rad(max_vertical_look_direction))
		if Input.is_action_pressed("zoom_in"):
			camera_spring.spring_length = clamp(camera_spring.spring_length - .5, min_zoom, max_zoom)
		elif Input.is_action_pressed("zoom_out"):
			camera_spring.spring_length = clamp(camera_spring.spring_length + .5, min_zoom, max_zoom)
		if Input.is_action_pressed("zoom_in") or Input.is_action_pressed("zoom_out"):
			for child in model.find_children("*", "VisualInstance3D"):
				child.set_layer_mask_value(1, camera_spring.spring_length != 0)
				child.set_layer_mask_value(2, camera_spring.spring_length == 0)
					
func _handle_ground_physics(dt:float)->void:
	var angled_speed = velocity.dot(wish_dir)
	var true_speed = base_speed - angled_speed
	if true_speed > 0:
		var accel = ground_accel * dt * base_speed
		accel = min(accel, true_speed)
		velocity += accel * wish_dir
	
	var control = max(velocity.length(), ground_deccel)
	var drop = control * ground_friction * dt
	var speed = max(velocity.length() - drop, 0.0)
	if velocity.length() > 0:
		speed /= velocity.length()
	velocity *= speed
	
	headbob(dt)

func _handle_air_physics(dt:float)->void:
	velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * dt
	var angled_speed = velocity.dot(wish_dir)
	var capped_speed = min((air_speed * wish_dir).length(), air_cap)
	var true_speed = capped_speed - angled_speed
	if true_speed > 0:
		var accel = air_accel * air_speed * dt
		accel = min(accel, true_speed)
		velocity += accel * wish_dir
	
	if is_on_wall():
		if is_steep(get_wall_normal()):
			self.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			self.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		clip_velocity(get_wall_normal(), 1, dt)

func clip_velocity(normal:Vector3, overbounce:float, _dt:float)->void:
	var backoff:float = velocity.dot(normal) * overbounce
	if backoff >= 0: return
	
	var change:Vector3 = normal * backoff
	velocity -= change
	
	var adjust:float = velocity.dot(normal)
	if adjust >= 0: return
	
	velocity -= normal * adjust
	
func is_steep(normal:Vector3)->bool:
	var max_slope = Vector3(0, 1, 0).rotated(Vector3(1.0, 0, 0), floor_max_angle).dot(Vector3(0, 1, 0))
	if normal.dot(Vector3(0, 1, 0)) < max_slope:
		return true
	return false

func _physics_process(dt: float) -> void:
	var input_dir = Input.get_vector("l", "r", "fw", "bw").normalized()
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump") or (auto_jump and Input.is_action_pressed("jump")):
			velocity.y = jump_velocity
		_handle_ground_physics(dt)
	else:
		_handle_air_physics(dt)
	move_and_slide()

func headbob(dt):
	headbob_time += dt * velocity.length()
	camera.transform.origin = Vector3(
		cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_STRENGTH,
		sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_STRENGTH,
		0
	)
