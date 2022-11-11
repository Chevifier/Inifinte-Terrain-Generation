extends Label

@export var NodeToDebug:Node3D
@export var player:CharacterBody3D
var FPS= 0
var Draw_Calls=0
var Frame_Time=0
var VRAM = 0
var show_debug = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if show_debug == false:
		text = ""
		return
	FPS = Engine.get_frames_per_second()
	Draw_Calls = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	Frame_Time = delta
	VRAM = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)/1024/1024
	var read_out = "FPS: " + str(FPS) + "\n" + \
		"Draw_Calls: " + str(Draw_Calls) + "\n" + \
		"Frame_Time: " + str(Frame_Time) + "\n" + \
		"VRAM: " + str(VRAM) + "\n" + \
		"Chunks: " + str(NodeToDebug.terrain_chunks.size()) +"\n" + \
		"POS:" +  str(player.global_position) + "\n" + \
		"Active Threads: " + str(NodeToDebug.get_active_threads())
	text = read_out


func _on_check_box_toggled(button_pressed):
	$Panel.visible = button_pressed
	show_debug = button_pressed


func _on_show_wireframe_toggled(button_pressed):
	NodeToDebug.render_wireframe = button_pressed


func _on_player_speed_value_changed(value):
	player.SPEED = value
