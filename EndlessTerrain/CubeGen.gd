@tool
extends MeshInstance3D

@export var update = false


# Called when the node enters the scene tree for the first time.
func _ready():
	gen_mesh()
	
func gen_mesh():
	var a_mesh = ArrayMesh.new()
	var vertices := PackedVector3Array([
		Vector3(0,1,0),
		Vector3(1,1,0),
		Vector3(1,1,1),
		Vector3(0,1,1),
		
		Vector3(0,0,0),
		Vector3(1,0,0),
		Vector3(1,0,1),
		Vector3(0,0,1),
		]
	)
	
	var indices := PackedInt32Array(
		[
			0,1,2,
			0,2,3,
			3,2,7,
			2,6,7,
			2,1,6,
			1,5,6,
			1,4,5,
			1,0,4,
			0,3,7,
			4,0,7,
			6,5,4,
			4,7,6
			
			
		]
	)
	
	var uvs = PackedVector2Array([
		Vector2(0,0),
		Vector2(1,0),
		Vector2(1,1),
		Vector2(0,1),
		
		Vector2(0,0),
		Vector2(1,0),
		Vector2(1,1),
		Vector2(0,1),
		
		
	]
		
		
		
		
		
	)
	
#	var array = []
#	array.resize(Mesh.ARRAY_MAX)
#	array[Mesh.ARRAY_VERTEX] = vertices
#	array[Mesh.ARRAY_INDEX] = indices
#	array[Mesh.ARRAY_TEX_UV] = uvs
#	a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,array)
	#mesh = a_mesh
	
	var suftool = SurfaceTool.new()
	suftool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(vertices.size()):
		suftool.set_uv(uvs[i])
		suftool.add_vertex(vertices[i])
	for i in indices:
		suftool.add_index(i)
	suftool.generate_normals()
	a_mesh = suftool.commit()
	mesh = a_mesh
	create_trimesh_collision()
		
		
		
	
	
	
	
	
	
	
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update:
		gen_mesh()
		update = false
