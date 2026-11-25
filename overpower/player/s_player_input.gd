extends System
class_name PlayerInputSystem

func query() -> QueryBuilder:
	return q.with_all([C_Player])
