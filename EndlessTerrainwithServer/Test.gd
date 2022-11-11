extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	create_cube()

func create_cube():
	var rs = RenderingServer
	var cube = rs.instance_create()
	var mesh = rs.mesh_create()
	var m = rs.make_sphere_mesh(100,100,1)
#	var surfacetool = SurfaceTool.new()
#
#
#	surfacetool.begin(Mesh.PRIMITIVE_TRIANGLES)
#
#	surfacetool.add_vertex(Vector3(-1,0,1))
#	surfacetool.add_vertex(Vector3(1,0,1))
#	surfacetool.add_vertex(Vector3(-1,0,-1))
#	surfacetool.add_vertex(Vector3(1,0,-1))
#
#	surfacetool.add_index(0)
#	surfacetool.add_index(2)
#	surfacetool.add_index(1)
#	surfacetool.add_index(1)
#	surfacetool.add_index(2)
#	surfacetool.add_index(3)
#	surfacetool.generate_normals()
#	surfacetool.generate_tangents()
#
#
#	var mesh_array  = surfacetool.commit_to_arrays()
	rs.instance_set_base(cube,m)
#
	#rs.mesh_add_surface_from_arrays(mesh,RenderingServer.PRIMITIVE_TRIANGLES,mesh_array)
	#show or hide instance
	rs.instance_set_visible(cube,true)
	#Tell the instance to be of type mesh
	#set the position of the cube
	rs.instance_set_transform(cube,Transform3D.IDENTITY)
	#what world is the mesh in
	rs.instance_set_scenario(cube,get_world_3d().scenario)

func create_collision():
	pass
	
	
