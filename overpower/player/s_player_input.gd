extends System
class_name PlayerInputSystem

func query() -> QueryBuilder:
	return q.with_all([C_Player]).enabled()
	
func process(entities: Array[Entity], _components: Array, _dt: float) -> void:
	for entity:Player in entities:
		var body := entity as Node as CharacterBody3D
		var head:Node3D = entity.head
		var cam_arm:SpringArm3D = entity.cam_arm
		var c_player := entity.get_component(C_Player) as C_Player
			
		#if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		body.rotate_y(-Input.get_last_mouse_velocity().x * c_player.look_sensitivity)
		head.rotate_x(-Input.get_last_mouse_velocity().y * c_player.look_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(c_player.min_vertical_look_direction), deg_to_rad(c_player.max_vertical_look_direction))
		
		if Input.is_action_pressed("zoom_in"):
			cam_arm.spring_length = clamp(cam_arm.spring_length - .5, c_player.min_zoom, c_player.max_zoom)
		elif Input.is_action_pressed("zoom_out"):
			cam_arm.spring_length = clamp(cam_arm.spring_length + .5, c_player.min_zoom, c_player.max_zoom)
