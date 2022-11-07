class_name TerrainChunk
extends MeshInstance3D
#Terrain size
@export_range(20,400, 1)var Terrain_Size := 200
#LOD scaling
@export_range(1, 100, 1) var resolution := 20
@export var Terrain_Max_Height = 5
#set the minimum to maximum lods 
#to change the terrain resolution
@export var chunk_lods : Array[int] = [2,4,8,15,20,50]
@export var LOD_distances : Array[int] = [2000,1500,1050,900,790,550]
#2D position in world space
var position_coord = Vector2()
var grid_coord = Vector2()

var vertices = PackedVector3Array()
var UVs = PackedVector2Array()
const CENTER_OFFSET = 0.5

var set_collision = false

func generate_terrain(noise:FastNoiseLite,coords:Vector2,size:float,initailly_visible:bool):
	Terrain_Size = size
	#set 2D position in world space
	grid_coord = coords
	position_coord = coords * size
	var a_mesh :ArrayMesh
	var surftool = SurfaceTool.new()
	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)
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
	if set_collision:
		create_collision()
	#set to invisible on start
	setChunkVisible(initailly_visible)

#create collision
func create_collision():
	if get_child_count() > 0:
		get_child(0).queue_free()
	create_trimesh_collision()
	
#update chunk to check if near viewer
func update_chunk(view_pos:Vector2,max_view_dis):
	var viewer_distance = position_coord.distance_to(view_pos)
	var _is_visible = viewer_distance <= max_view_dis
	#setChunkVisible(_is_visible)

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
	queue_free()
#set chunk visibility
func setChunkVisible(_is_visible):
	visible = _is_visible

#get chunk visible
func getChunkVisible():
	return visible

