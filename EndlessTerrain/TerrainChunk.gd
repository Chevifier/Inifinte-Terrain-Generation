class_name TerrainChunk
extends MeshInstance3D
#Terrain size
@export_range(20,400, 1)var Terrain_Size := 200
#LOD scaling
@export_range(2, 100, 1) var resolution := 20
@export var Terrain_Max_Height = 5
#set the minimum to maximum lods 
#to change the terrain resolution
var chunk_lods = [5,20,50,80]
#2D position in world space
var position_coord = Vector2()
const CENTER_OFFSET = 0.5
var min_height = 0
var max_height = 1
var set_collision = false
func generate_terrain(thread,noise:FastNoiseLite,coords:Vector2,size:float,initailly_visible:bool):
	Terrain_Size = size
	#set 2D position in world space
	position_coord = coords * size
	var a_mesh :ArrayMesh
	var surftool = SurfaceTool.new()
	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var verty = 0.0
	#use resolution to loop
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
			vertex.y = noise.get_noise_2d(position.x+vertex.x,position.z+vertex.z) * Terrain_Max_Height
			#create UVs using percentage
			var uv = Vector2()
			uv.x = percent.x
			uv.y = percent.y
			#set UV and add Vertex
			surftool.set_uv(uv)
			surftool.add_vertex(vertex)
	#created indices for triangle
	#clockwise
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
	#Generate Normal Map
	surftool.generate_normals()
	#create Array Mesh from Data
	a_mesh = surftool.commit()
	#assign Array Mesh to mesh
	mesh = a_mesh
	if set_collision == true:
		create_collision()
	#update_shader()
	#set to invisible on start
	setChunkVisible(initailly_visible)
	#call thread finished when safe
	call_deferred("thread_finished",thread)
	

func update_shader():
	var mat = get_active_material(0)
	mat.set_shader_parameter("min_height",min_height)
	mat.set_shader_parameter("max_height",max_height)
	
	
func draw_sphere(pos:Vector3):
	var ins = MeshInstance3D.new()
	add_child(ins)
	ins.position = pos
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	ins.mesh = sphere

#create collision
func create_collision():
	if get_child_count() > 0:
		for i in get_children():
			i.free()
	create_trimesh_collision()
	


#joins and frees thread when not in use
func thread_finished(thread:Thread):
	if thread != null:
		thread.wait_to_finish()

#update chunk to check if near viewer
func update_chunk(view_pos:Vector2,max_view_dis):
	var viewer_distance = position_coord.distance_to(view_pos)
	var _is_visible = viewer_distance <= max_view_dis
	
	setChunkVisible(_is_visible)
#update mesh based on distance
func update_lod(view_pos:Vector2):
	var viewer_distance = position_coord.distance_to(view_pos)
	var update_terrain = false
	var new_lod = 0
	if viewer_distance > 1000:
		new_lod = chunk_lods[0]
	if viewer_distance <= 1000:
		new_lod = chunk_lods[1]
	if viewer_distance < 900:
		new_lod = chunk_lods[2]
	if viewer_distance < 500:
		new_lod = chunk_lods[3]
		#if terrain is at highest detail create collision shape
		set_collision = true
	# if resolution is not equal to new resolution
	#set update terrain to true
	if resolution != new_lod:
		resolution = new_lod
		update_terrain = true
	return update_terrain

#remove chunk
func free_chunk():
	queue_free()
#set chunk visibility
func setChunkVisible(_is_visible):
	visible = _is_visible

#get chunk visible
func getChunkVisible():
	return visible

