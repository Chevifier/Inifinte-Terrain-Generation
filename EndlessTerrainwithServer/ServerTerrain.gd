
extends Node3D

@export_range(20,400, 1) var Terrain_Size := 100
@export_range(1, 100, 1) var resolution := 30
#center terrain
const center_offset := 0.5
@export var Terrain_Max_Height = 5
@export var noise_offset = 0.5
@export var create_collision = false
@export var remove_collision = false

@export var material:Material
@export var noise:FastNoiseLite
#RIDs
var instance:RID
var mesh_instance:RID
var mesh_data = []
var mesh:ArrayMesh

var collision_body:RID
var collision_shape:ConcavePolygonShape3D
@export var chunk_position :=Vector3()
var chunk_transform = Transform3D()

var rs = RenderingServer
var ps = PhysicsServer3D

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_terrain()

func generate_terrain():
	delete_chunk()
	var surftool = SurfaceTool.new()

	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in resolution+1:
		for x in resolution+1:
			var percent = Vector2(x,z)/resolution
			var pointOnMesh = Vector3((percent.x-center_offset),0,(percent.y-center_offset))
			var vertex = pointOnMesh * Terrain_Size;
			vertex.y = noise.get_noise_2d(vertex.x*noise_offset,vertex.z*noise_offset) * Terrain_Max_Height
			var uv = Vector2()
			uv.x = percent.x
			uv.y = percent.y
			surftool.set_uv(uv)
			surftool.add_vertex(vertex)
	var vert = 0
	for z in resolution:
		for x in resolution:
			surftool.add_index(vert+0)
			surftool.add_index(vert+1)
			surftool.add_index(vert+resolution+1)
			surftool.add_index(vert+resolution+1)
			surftool.add_index(vert+1)
			surftool.add_index(vert+resolution+2)
			vert+=1
		vert+=1
	surftool.generate_normals()
	mesh_data = surftool.commit_to_arrays()
	instance = rs.instance_create()
	mesh_instance = rs.mesh_create()
	rs.instance_set_base(instance,mesh_instance)
	rs.mesh_add_surface_from_arrays(mesh_instance,RenderingServer.PRIMITIVE_TRIANGLES,mesh_data)
	rs.instance_set_scenario(instance,get_world_3d().scenario)
	rs.mesh_surface_set_material(mesh_instance,0,material)
	rs.instance_set_transform(instance,chunk_transform)
	chunk_transform.origin = chunk_position
	generate_collision()
	
	
var last_res = 0
var last_size = 0
var last_height = 0
var last_offset = 0
var last_pos = Vector3()

#func _process(delta):
#	if resolution!=last_res or Terrain_Size!=last_size or \
#		Terrain_Max_Height!=last_height or noise_offset!=last_offset or last_pos != chunk_position:
#		generate_terrain()
#		last_res = resolution
#		last_size = Terrain_Size
#		last_height = Terrain_Max_Height
#		last_offset = noise_offset
#		last_pos = chunk_position
#
#	if remove_collision:
#		clear_collision()
#		remove_collision = false
#	if create_collision:
#		generate_collision()
#		create_collision = false

func generate_collision():
	clear_collision()
	collision_body = ps.body_create()
	ps.body_set_space(collision_body,get_world_3d().space)
	ps.body_set_mode(collision_body,PhysicsServer3D.BODY_MODE_STATIC)
	ps.body_set_collision_layer(collision_body,1)
	ps.body_set_collision_mask(collision_body,2)
	ps.body_set_state(collision_body,PhysicsServer3D.BODY_STATE_TRANSFORM,chunk_transform)
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,mesh_data)
	collision_shape = mesh.create_trimesh_shape()
	var mesh_shape = ps.concave_polygon_shape_create()
	ps.shape_set_data(mesh_shape,mesh_data[Mesh.ARRAY_VERTEX])
	ps.body_add_shape(collision_body,collision_shape,Transform3D.IDENTITY)
	
	
	
	
func delete_chunk():
	if instance:
		rs.free_rid(instance)
	if mesh_instance:
		rs.free_rid(mesh_instance)

func clear_collision():
	if collision_body:
		ps.free_rid(collision_body)

func _exit_tree():
	delete_chunk()
	clear_collision()
	
	
