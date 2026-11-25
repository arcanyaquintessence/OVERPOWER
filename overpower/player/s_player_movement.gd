extends System
class_name PlayerMovementSystem

func query() -> QueryBuilder:
	return q.with_all([C_Player, C_GroundSpeed, C_AirSpeed, C_JumpSpeed]).enabled()
	
func _ground_process(entity:Player, dt:float)->void:
	var body := entity as Node as CharacterBody3D
	var c_player := entity.get_component(C_Player) as C_Player
	var c_ground_speed := entity.get_component(C_GroundSpeed) as C_GroundSpeed
	
	var angled_speed = body.velocity.dot(c_player.wish_dir)
	var true_speed = c_ground_speed.speed - angled_speed
	if true_speed > 0:
		var accel = c_ground_speed.accel * c_ground_speed.speed * dt
		accel = min(accel, true_speed)
		body.velocity += accel * c_player.wish_dir
		
	var cam = entity.cam
	c_player.headbob_time += dt * body.velocity.length()
	cam.transform.origin = Vector3(
		cos(c_player.headbob_time * c_player.HEADBOB_FREQUENCY * 0.5) * c_player.HEADBOB_STRENGTH,
		sin(c_player.headbob_time * c_player.HEADBOB_FREQUENCY) * c_player.HEADBOB_STRENGTH,
		0)
	
func _air_process(entity:Player, dt:float)->void:
	var body := entity as Node as CharacterBody3D
	var c_player := entity.get_component(C_Player) as C_Player
	var c_air_speed := entity.get_component(C_AirSpeed) as C_AirSpeed
	
	var angled_speed = body.velocity.dot(c_player.wish_dir)
	var capped_speed = min((c_air_speed.speed * c_player.wish_dir).length(), c_air_speed.air_cap)
	var true_speed = capped_speed - angled_speed
	if true_speed > 0:
		var accel = c_air_speed.accel * c_air_speed.speed * dt
		accel = min(accel, true_speed)
		body.velocity += accel * c_player.wish_dir
	body.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * dt

func process(entities: Array[Entity], _components: Array, dt: float) -> void:
	var input_dir := Input.get_vector("l", "r", "fw", "bw").normalized()
	for entity:Player in entities:
		var body := entity as Node as CharacterBody3D
		var c_player := entity.get_component(C_Player) as C_Player
		var c_ground_speed := entity.get_component(C_GroundSpeed) as C_GroundSpeed
		var c_jump_speed := entity.get_component(C_JumpSpeed) as C_JumpSpeed
		
		c_player.wish_dir = Vector3(input_dir.x, 0.0, input_dir.y) * c_ground_speed.speed
		if body.is_on_floor():
			if Input.is_action_pressed("jump"):
				body.velocity.y = c_jump_speed.speed
			_ground_process(entity, dt)
		else:
			_air_process(entity, dt)
		body.move_and_slide()
