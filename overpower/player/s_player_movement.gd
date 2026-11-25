extends System
class_name PlayerMovementSystem

func query() -> QueryBuilder:
	return q.with_all([C_Player, C_MoveSpeed])

func process(entities: Array[Entity], _components: Array, _delta: float) -> void:
	var input_dir := Input.get_vector("l", "r", "fw", "bw")
	for entity in entities:
		var body := entity as Node as CharacterBody3D
		var c_speed := entity.get_component(C_MoveSpeed) as C_MoveSpeed
		body.velocity = Vector3(input_dir.x, 0, input_dir.y) * c_speed.speed
		body.move_and_slide()
