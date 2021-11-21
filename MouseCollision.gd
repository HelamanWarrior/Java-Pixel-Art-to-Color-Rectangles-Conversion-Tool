extends Area2D

func _ready():
	scale = Global.pixel_scale

func _process(delta):
	global_position = get_global_mouse_position().snapped(Global.pixel_scale)
	global_position.x = clamp(global_position.x, Global.canvas_start.x, Global.canvas_end.x)
	global_position.y = clamp(global_position.y, Global.canvas_start.y, Global.canvas_end.y)
