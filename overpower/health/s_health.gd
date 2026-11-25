extends System
class_name S_Health

func query() -> QueryBuilder:
	return q.with_all([C_Health])
	
func damage(c_health:C_Health, _damage) -> void:
	c_health.health = clamp(c_health.health - _damage, 0, c_health.max_health)
	
func process(entities: Array[Entity], components: Array, _dt: float) -> void:
	for entity in entities:
		var c_health = entity.get_component(C_Health) as C_Health
		damage(c_health, 1)
