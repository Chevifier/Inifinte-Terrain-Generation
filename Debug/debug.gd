extends Label

@export var NodeToDebug:Node3D
@export var player:CharacterBody3D
var FPS= 0
var Draw_Calls=0
var Frame_Time=0
var VRAM = 0
var show_debug = true
var chunk_count = 0
var active_threads = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if show_debug == false:
		text = ""
		return
	FPS = Engine.get_frames_per_second()
	Draw_Calls = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	Frame_Time = delta
	VRAM = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)/1024/1024
	if NodeToDebug:
		chunk_count = NodeToDebug.terrain_chunks.size()
		active_threads = NodeToDebug.get_active_threads()
	else:
		chunk_count = 0
		active_threads = 1
	var read_out = "FPS: %d\nDraw_Calls: %d \n" % [FPS,Draw_Calls]
	read_out += "Frame_Time: %f \nVRAM: %f \n" % [Frame_Time,VRAM]
	read_out += "Chunks: %d \nPOS: %s \nActive Threads: %d" % [chunk_count,player.position,active_threads]
		
	text = read_out


func _on_check_box_toggled(button_pressed):
	$Panel.visible = button_pressed
	show_debug = button_pressed


func _on_show_wireframe_toggled(button_pressed):
	if NodeToDebug:
		NodeToDebug.render_wireframe = button_pressed


func _on_player_speed_value_changed(value):
	if player:
		player.SPEED = value
	else:
		print("Player not set in Debug UI")
