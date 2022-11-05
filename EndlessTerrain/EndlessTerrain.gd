extends Node3D

@export var chunkSize = 400
@export var terrain_height = 20
@export var view_distance = 4000
@export var viewer :Marker3D
var chunk_lods = [100,50,25,10]
@export var chunk_mesh_scene : PackedScene
var viewer_position = Vector2()
var terrain_chunks = {}
var chunksvisible=0
var last_visible_chunks = []
@export var noise:FastNoiseLite

#threads to create
@export var thread_count = 10
#array of threads to generate terrain
var threads = []


func _ready():
	#create threads and add to array
	for i in thread_count:
		threads.append(Thread.new())
	#set the total chunks to be visible
	chunksvisible = roundi(view_distance/chunkSize)
	set_wireframe()
	updateVisibleChunk()
	
func set_wireframe():
	RenderingServer.set_debug_generate_wireframes(true)
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	
	
	
func _process(delta):
	viewer_position.x = viewer.global_position.x
	viewer_position.y = viewer.global_position.z
	updateVisibleChunk()

func updateVisibleChunk():
	#hide chunks that were made and out of view
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
				if terrain_chunks[view_chunk_coord].update_lod(viewer_position):
					terrain_chunks[view_chunk_coord].generate_terrain(null,noise,view_chunk_coord,chunkSize,true)
				#if chunk is visible add it to last visible chunks
				if terrain_chunks[view_chunk_coord].getChunkVisible():
					last_visible_chunks.append(terrain_chunks[view_chunk_coord])
			else:
				#print(view_chunk_coord)
			#if chunk doesnt exist, create chunk
				var chunk :TerrainChunk= chunk_mesh_scene.instantiate()
				add_child(chunk)
				#set chunk parameters
				chunk.Terrain_Max_Height = terrain_height
				#set chunk world position
				var pos = view_chunk_coord*chunkSize
				var world_position = Vector3(pos.x,0,pos.y)
				chunk.global_position = world_position
				chunk.generate_terrain(null,noise,view_chunk_coord,chunkSize,false)
				terrain_chunks[view_chunk_coord] = chunk
				#DO AFTER CODE WORKS
				#use array of threads to generate chunk mesh
				#loop through all threads
				#for thread in threads:
					#if thread is not started
					#use it to start generating the chunk
					#then break out of loop to prevent using other inactive threads
					#if thread.is_started() == false:
						#thread.start(chunk.generate_terrain.bind(thread,noise,view_chunk_coord,chunkSize))
						#break;
				#add the chunk reference using the
				#view_position_coords as the key
				#print(terrain_chunks.size())
				
#clear all the threads before exiting
func _exit_tree():
	for thread in threads:
		if thread.is_alive():
			thread.wait_to_finish()
