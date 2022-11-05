extends Label

var FPS= 0
var Draw_Calls=0
var Frame_Time=0
var VRAM = 0
var OBJECTS = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	FPS = Engine.get_frames_per_second()
	Draw_Calls = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	Frame_Time = delta
	VRAM = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)/1024/1024
	OBJECTS = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)
	var read_out = "FPS: " + str(FPS) + "\n" + \
		"Draw_Calls: " + str(Draw_Calls) + "\n" + \
		"Frame_Time: " + str(Frame_Time) + "\n" + \
		"VRAM: " + str(VRAM) + "\n" + \
		"OBJECTS: " + str(OBJECTS)
	
	text = read_out
