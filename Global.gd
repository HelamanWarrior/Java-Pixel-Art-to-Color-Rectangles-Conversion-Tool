extends Node

signal mouse_under_pixel(is_under_pixel, pixel_object)

var pixel_scale = Vector2(16, 16)

var pixel_array = []
var pixel_instance_array = []

var canvas_size = Vector2(320, 320)
var local_canvas_size = Vector2(0, 0)
var canvas_pos = Vector2(0, 0)
var canvas = null
var canvas_start = Vector2(0, 0)
var canvas_end = Vector2(0, 0)

var screen_rel_mouse_pos = Vector2(0, 0)
var canvas_rel_mouse_pos = Vector2(0, 0)

var current_pixel_color = Color.white

var generated_code_text = []
var java_pixel_scale = Vector2(16, 16)

func _ready():
	local_canvas_size = canvas_size / pixel_scale
	pixel_array.resize(local_canvas_size.x * local_canvas_size.y)
	
	pixel_instance_array.resize(local_canvas_size.x * local_canvas_size.y)
	
	for i in range(pixel_array.size()):
		pixel_array[i] = 0
	

