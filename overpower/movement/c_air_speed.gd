extends Component
class_name C_AirSpeed

@export var speed: float = 60.0
@export var accel: float = 30.0
@export var air_cap:float = .85

func _init(_speed: float = 60.0, _accel: float = 30.0, _air_cap:float = .85) -> void:
	speed = _speed
	accel = _accel
	air_cap = _air_cap
