extends Component
class_name HealthComponent

@export var death_component:DeathComponent

@export var max_health:float = 100
@export var health:float:
	set(new):
		health = clamp(new, 0, max_health)
		if health == 0 and death_component:
			death_component._on_death()
		else:
			get_parent().queue_free()

func _ready() -> void:
	health = max_health

func damage(change:float)->void:
	if change == 0:
		return
	health -= change
	if change > 0:
		#dmg effect
		pass
	else:
		#heal effect
		pass
