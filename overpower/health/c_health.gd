extends Component
class_name C_Health

@export var max_health:float
@export var health:float
		
func _init(_health:float = 100.0) -> void:
	max_health = _health
	health = _health
