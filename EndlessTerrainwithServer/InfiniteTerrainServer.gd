extends Node3D

@export var chunkSize = 100
@export var terrain_height = 20
@export var view_distance = 500
@export var viewer :CharacterBody3D
@export_category("Terrain Data")
@export var material:Material
@export var noise:FastNoiseLite
@export_category("Terrain LODs")
@export_range(1,100, 1) var LOD0 := 100
@export_range(1,1000, 1) var LOD0_Distance := 150
@export_range(1,100, 1) var LOD1 := 75
@export_range(1,1000, 1) var LOD1_Distance := 200
@export_range(1,100, 1) var LOD2 := 60
@export_range(1,1000, 1) var LOD2_Distance := 250
@export_range(1,100, 1) var LOD3 := 50
@export_range(1,1000, 1) var LOD3_Distance := 350
@export_range(1,100, 1) var LOD4 := 30
@export_range(1,1000, 1) var LOD4_Distance := 550

@export_category("Debug")
var render_wireframe = true
var viewer_position = Vector2()
var terrain_chunks = {}
var generation_queue = []
var chunksvisible=0
var last_visible_chunks = []
@export var use_threads = false
@export var thread_count = 10
#array of threads to generate terrain
var threads = []
var active_threads = 0

func _ready():
	for i in thread_count:
		threads.append(Thread.new())
	#set the total chunks to be visible
	chunksvisible = roundi(view_distance/chunkSize)
	RenderingServer.set_debug_generate_wireframes(true)
	set_wireframe(render_wireframe) 
	#First call to create the chunks
	updateVisibleChunk(true)
	#second call to update LODs
	updateVisibleChunk(true)
	
	
func set_wireframe(draw_wireframe:bool):
	if draw_wireframe:
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	else:
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED


func _process(delta):
	set_wireframe(render_wireframe)
	viewer_position.x = viewer.global_position.x
	viewer_position.y = viewer.global_position.z
	updateVisibleChunk(false)

func updateVisibleChunk(initail_chunks):
	#hide chunks that were are out of view
	for chunk in last_visible_chunks:
		chunk.setChunkVisible(false)
	last_visible_chunks.clear()
	#get grid position
	var currentX = roundi(viewer_position.x/chunkSize)
	var currentY = roundi(viewer_position.y/chunkSize)
	#get all the chunks within visiblity range
	for yOffset in range(-chunksvisible,chunksvisible):
		for xOffset in range(-chunksvisible,chunksvisible):
			#create a new chunk coordinate 
			var view_chunk_coord = Vector2(currentX-xOffset,currentY-yOffset)
			#check if chunk was already created
			if terrain_chunks.has(view_chunk_coord):
				#if chunk exist update the chunk passing viewer_position and view_distance
				terrain_chunks[view_chunk_coord].update_chunk(viewer_position,view_distance)
				#update chunk LODs
				if terrain_chunks[view_chunk_coord].update_lod(viewer_position):
					terrain_chunks[view_chunk_coord].set_generation_data(noise,view_chunk_coord,chunkSize,true)
					if use_threads == false or initail_chunks:
						terrain_chunks[view_chunk_coord].generate_terrain()
					else:
						for thread in threads:
							if thread.is_started() == false:
								thread.start(terrain_chunks[view_chunk_coord].generate_terrain.bind(thread))
								break
							
				#if chunk is visible add it to last visible chunks
				if terrain_chunks[view_chunk_coord].getChunkVisible():
					last_visible_chunks.append(terrain_chunks[view_chunk_coord])
			else:
				#if chunk doesnt exist, create chunk
				var pos = view_chunk_coord*chunkSize
				#set chunk world position
				var world_position = Vector3(pos.x,0,pos.y)
				#set chunk parameters
				var chunk = ServerTerrainChunk.new(world_position,material,get_world_3d().scenario,get_world_3d().space)
				terrain_chunks[view_chunk_coord] = chunk
				chunk.Terrain_Max_Height = terrain_height
				chunk.set_generation_data(noise,view_chunk_coord,chunkSize,false)
				var lods = [LOD4,LOD3,LOD2,LOD1,LOD0]
				var lods_dis = [LOD4_Distance,LOD3_Distance,LOD2_Distance,LOD1_Distance,LOD0_Distance]

				
				chunk.setLODData(lods,lods_dis)
				if use_threads == false or initail_chunks:
					chunk.generate_terrain()
				else:
					for thread in threads:
						if thread.is_started() == false:
							thread.start(chunk.generate_terrain.bind(thread))
							break
				

##check if we should remove chunk from scene
	for chunk in terrain_chunks:
		if terrain_chunks[chunk].should_remove(viewer_position,view_distance*2):
			#delete chunk mesh RIDs
			terrain_chunks[chunk].free_chunk()
			#remove from terrain
			if terrain_chunks.has(terrain_chunks[chunk].grid_coord):
				terrain_chunks.erase(chunk)

func _exit_tree():
	for thread in threads:
		if thread.is_started():
			thread.wait_to_finish()
			active_threads -=1

func get_active_threads():
	active_threads = 0
	for i in threads:
		if i.is_alive():
			active_threads += 1
	return active_threads

