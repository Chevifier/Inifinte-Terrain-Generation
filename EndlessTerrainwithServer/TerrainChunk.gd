class_name ServerTerrainChunk
@export_range(20,400, 1) var Terrain_Size := 100
@export_range(1, 100, 1) var resolution := 4
#set the minimum to maximum lods 
#to change the terrain resolution
@export var chunk_lods : Array[int] = [5,20,40,45,50]
@export var LOD_distances : Array[int] = [400,350,250,200,150]
#2D position in world space
var position_coord = Vector2()
var grid_coord = Vector2()
var Terrain_Max_Height = 5
#center terrain
const CENTER_OFFSET := 0.5

var create_collision = false
var remove_collision = false
#RIDs
var instance:RID
var mesh_instance:RID
var collision_body:RID
var mesh_data = []
var mesh:ArrayMesh
var material

var collision_shape:ConcavePolygonShape3D
var chunk_position :=Vector3()
var chunk_transform = Transform3D()

var rs = RenderingServer
var ps = PhysicsServer3D
var scenario#get_world_3d.scenario
var space#get_world_3d.space
var noise
#weather or not to create collision
var set_collision = false
var chunk_visible = true
var mutex = Mutex.new()

func _init(position,_material,_scenario,_space):
	self.chunk_position = position
	self.scenario = _scenario
	self.space = _space
	self.material = _material

func setLODData(lods,lods_dis):
	chunk_lods = lods
	LOD_distances = lods_dis
	
func set_generation_data(noise:FastNoiseLite,coords:Vector2,size:float,initailly_visible:bool):
	self.noise = noise
	grid_coord = coords
	Terrain_Size = size
	#set 2D position in world space
	position_coord = coords * size
	chunk_visible=initailly_visible
	
func generate_terrain(thread = null):
	mutex.lock()
	var last_instance
	var surftool = SurfaceTool.new()
	#get a copy of the last instance
	if instance:
		last_instance = instance
	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in resolution+1:
		for x in resolution+1:
			#get the percentage of the current point
			var percent = Vector2(x,z)/resolution
			#create the point on the mesh
			#offset it by -0.5 to make origin centered
			var pointOnMesh = Vector3((percent.x-CENTER_OFFSET),0,(percent.y-CENTER_OFFSET))
			#multiplay it by the Terrain size to get vertex position
			var vertex = pointOnMesh * Terrain_Size;
			#set the height of the vertex by noise
			#pass position to make noise continueous
			vertex.y = noise.get_noise_2d(chunk_position.x+vertex.x,chunk_position.z+vertex.z) * Terrain_Max_Height
			#create UVs using percentage
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
	rs.instance_set_scenario(instance,scenario)
	chunk_transform.origin = chunk_position
	rs.instance_set_transform(instance,chunk_transform)
	rs.mesh_add_surface_from_arrays(mesh_instance,RenderingServer.PRIMITIVE_TRIANGLES,mesh_data)
	rs.mesh_surface_set_material(mesh_instance,0,material)
	mutex.unlock()
	#remove the last instance
	#this prevents blinking
	if last_instance:
		rs.free_rid(last_instance)
	call_deferred("thread_complete",thread)
func thread_complete(thread):
	if thread != null:
		thread.wait_to_finish()
		
	if set_collision:
		generate_collision()
	
func generate_collision():
	clear_collision()
	collision_body = ps.body_create()
	ps.body_set_space(collision_body,space)
	ps.body_set_mode(collision_body,PhysicsServer3D.BODY_MODE_STATIC)
	ps.body_set_collision_layer(collision_body,0b1)
	ps.body_set_collision_mask(collision_body,0b1)
	ps.body_set_state(collision_body,PhysicsServer3D.BODY_STATE_TRANSFORM,chunk_transform)
	
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,mesh_data)
	collision_shape = mesh.create_trimesh_shape()
	var mesh_shape = ps.concave_polygon_shape_create()
	ps.shape_set_data(mesh_shape,mesh_data[Mesh.ARRAY_VERTEX])
	ps.body_add_shape(collision_body,collision_shape,Transform3D.IDENTITY)
	

#update chunk to check if near viewer
func update_chunk(view_pos:Vector2,max_view_dis):
	var viewer_distance = position_coord.distance_to(view_pos)
	var _is_visible = viewer_distance <= max_view_dis
	setChunkVisible(_is_visible)

#SLOW
func should_remove(view_pos:Vector2,max_view_dis):
	var remove = false
	var viewer_distance = position_coord.distance_to(view_pos)
	if viewer_distance > max_view_dis:
		remove = true
	return remove
	
#update mesh based on distance
func update_lod(view_pos:Vector2):
	var viewer_distance = position_coord.distance_to(view_pos)
	var update_terrain = false
	var new_lod = chunk_lods[0]
	if chunk_lods.size() != LOD_distances.size():
		print("ERROR Lods and Distance count mismatch")
		return
	for i in range(chunk_lods.size()):
		var lod = chunk_lods[i]
		var dis = LOD_distances[i]
		if viewer_distance < dis:
			new_lod = lod
	#if terrain is at highest detail create collision shape
	if new_lod >= chunk_lods[chunk_lods.size()-2]:
		set_collision = true
	else:
		set_collision = false
	# if resolution is not equal to new resolution
	#set update terrain to true
	if resolution != new_lod:
		resolution = new_lod
		update_terrain = true
	return update_terrain

#remove chunk
func free_chunk():
	if instance:
		rs.free_rid(instance)
	if mesh_instance:
		rs.free_rid(mesh_instance)
		
#set chunk visibility
func setChunkVisible(is_visible):
	chunk_visible = is_visible
	

#get chunk visible
func getChunkVisible():
	return chunk_visible


func clear_collision():
	if collision_body:
		ps.free_rid(collision_body)
