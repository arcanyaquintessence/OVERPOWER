extends Component
class_name C_GroundSpeed

@export var speed: float = 7.0
@export var accel: float = 14.0

func _init(_speed: float = 7.0, _accel: float = 14.0) -> void:
	speed = _speed
	accel = _accel
