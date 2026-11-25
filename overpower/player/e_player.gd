extends Entity
class_name Player

@onready var head: Node3D = %Head
@onready var cam_arm: SpringArm3D = %CameraArm
@onready var cam: Camera3D = %Camera3D

func on_ready() -> void:
	add_to_group("plr")
