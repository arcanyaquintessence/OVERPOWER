extends Node3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	#setup arrays
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	#actual mesh stuff
	
	verts = PackedVector3Array([
		Vector3(0, 0, 0),
		Vector3(0, 0, 1),
		Vector3(1, 0, 0),
		Vector3(1, 0, 1),
	])
	
	uvs = PackedVector2Array([
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(1, 1),
	])
	
	normals = PackedVector3Array([
		Vector3.UP,
		Vector3.UP,
		Vector3.UP,
		Vector3.UP,
	])
	
	#the numbers correspond to the indexes in verts
	indices = PackedInt32Array([
		0, 2, 1,
		2, 3, 1,
	])
	
	#apply mesh
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	mesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
