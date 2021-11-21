extends Node2D

var pixel = preload("res://Pixel.tscn")

var is_mouse_under_pixel = false
var is_mouse_under_canvas = false

var current_pixel = null
var canvas_size = Vector2(0, 0)
var canvas_pos = Vector2(0, 0)

onready var mouse_position_label = $CanvasLayer/Control/MousePosition
onready var canvas_display = $CanvasLayer/Control/CanvasDisplay
onready var debug_label = $RichTextLabel
onready var generated_code = $CanvasLayer/Control/GeneratedCode

func _ready():
	Global.connect("mouse_under_pixel", self, "_mouse_under_pixel")
	Global.canvas = self
	
	canvas_pos = canvas_display.rect_position
	Global.canvas_pos = canvas_pos
	
	var half_pixel_size = Global.pixel_scale * 0.5
	
	Global.canvas_start = Global.canvas_pos + half_pixel_size
	Global.canvas_end = Global.canvas_pos + Global.canvas_size - half_pixel_size

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	
	if mouse_pos.x > Global.canvas_start.x && mouse_pos.x < Global.canvas_end.x && mouse_pos.y > Global.canvas_start.y && mouse_pos.y < Global.canvas_end.y:
		is_mouse_under_canvas = true
	else:
		is_mouse_under_canvas = false
	
	Global.screen_rel_mouse_pos = mouse_pos.snapped(Global.pixel_scale) / Global.pixel_scale
	Global.canvas_rel_mouse_pos = Global.screen_rel_mouse_pos - (Global.canvas_start / Global.pixel_scale)
	
	Global.canvas_rel_mouse_pos.x = clamp(Global.canvas_rel_mouse_pos.x, 0, Global.local_canvas_size.x)
	Global.canvas_rel_mouse_pos.y = clamp(Global.canvas_rel_mouse_pos.y, 0, Global.local_canvas_size.y)
	
	debug_label.text = str(Global.pixel_array)
	
	var pixel_hover_array_val = Global.canvas_rel_mouse_pos.x + (Global.canvas_rel_mouse_pos.y * Global.local_canvas_size.x)
	var pixel_hover = null
	
	if pixel_hover_array_val < Global.pixel_instance_array.size():
		pixel_hover = Global.pixel_instance_array[pixel_hover_array_val]
	
	if Input.is_action_pressed("click") and is_mouse_under_canvas:
		if is_instance_valid(pixel_hover):
			pixel_hover.queue_free()
		
		var pixel_instance = pixel.instance()
		add_child(pixel_instance)
		
		pixel_instance.global_position = mouse_pos.snapped(Global.pixel_scale)
		pixel_instance.canvas_rel_pos = Global.canvas_rel_mouse_pos
		Global.pixel_array[Global.canvas_rel_mouse_pos.x + (Global.canvas_rel_mouse_pos.y * Global.local_canvas_size.x)] = 1
		Global.pixel_instance_array[Global.canvas_rel_mouse_pos.x + (Global.canvas_rel_mouse_pos.y * Global.local_canvas_size.x)] = pixel_instance
		
		var line = get_drawing_rectangle_code(pixel_instance.canvas_rel_pos)
		
		if Global.generated_code_text.find(line) == -1:
			Global.generated_code_text.append(line)
		generated_code.text = str(optimize_the_code()).replace("[", "").replace("]", "").replace(";, ", ";\n")
	
	if Input.is_action_pressed("right_click") and is_instance_valid(pixel_hover):
		var line = get_drawing_rectangle_code(pixel_hover.canvas_rel_pos)
		
		Global.generated_code_text.erase(line)
		
		pixel_hover.queue_free()
		is_mouse_under_pixel = false
		Global.pixel_array[Global.canvas_rel_mouse_pos.x + (Global.canvas_rel_mouse_pos.y * Global.local_canvas_size.x)] = 0
		Global.pixel_instance_array[Global.canvas_rel_mouse_pos.x + (Global.canvas_rel_mouse_pos.y * Global.local_canvas_size.x)] = null
		
		generated_code.text = str(optimize_the_code()).replace("[", "").replace("]", "").replace(";, ", ";\n")
		
		print(optimize_the_code())
	
	mouse_position_label.text = str(Global.canvas_rel_mouse_pos)

func optimize_the_code():
	#Get pixel positions
	var empty_pixel = true
	
	var pixel_positions = []
	
	var vector_pos = Vector2(0, 0)
	var max_size = Global.local_canvas_size * Global.java_pixel_scale
	
	var i = 0
	var yi = 0
	for x in range(Global.local_canvas_size.x * Global.local_canvas_size.y):
		if i < Global.local_canvas_size.x:
			vector_pos = Vector2(i, yi) * Global.java_pixel_scale
		else:
			i = 0
			yi += 1
			vector_pos = Vector2(0, yi) * Global.java_pixel_scale
		pixel_positions.append(vector_pos)
		i += 1
	
	#Get rectanges
	var previous_color_rect = null
	
	i = 0
	
	var rect_start_locations = []
	var rect_end_locations = []
	
	for pixel in Global.pixel_instance_array:
		if pixel != null:
			if empty_pixel == true:
				rect_start_locations.append(pixel_positions[i])
			
			empty_pixel = false
		else:
			if empty_pixel == false: #Pixel just changed
				rect_end_locations.append(pixel_positions[i] - rect_start_locations[rect_start_locations.size() - 1] + Vector2(0, Global.java_pixel_scale.y))
			
			empty_pixel = true
		i += 1
	print(rect_end_locations)
	
	#Generate output code for rectangles
	var code = []
	
	for loc in range(rect_start_locations.size()):
		code.append(get_drawing_sized_rectangle_code(rect_start_locations[loc], rect_end_locations[loc]))
	
	return code

func get_drawing_rectangle_code(pos):
	return "g.fillRect(" + str((pos.x * Global.java_pixel_scale.x) - Global.java_pixel_scale.x) + ", " + str((pos.y * Global.java_pixel_scale.y) - Global.java_pixel_scale.y) + ", " + str(Global.java_pixel_scale.x) + ", " + str(Global.java_pixel_scale.y) + ");"

func get_drawing_sized_rectangle_code(pos, size):
	return "g.fillRect(" + str(pos.x - Global.java_pixel_scale.x) + ", " + str(pos.y - Global.java_pixel_scale.y) + ", " + str(size.x) + ", " + str(size.y) + ");"

func _on_ColorPickerButton_color_changed(color):
	Global.current_pixel_color = color

func _on_CopyCode_pressed():
	OS.set_clipboard(generated_code.text)

func _exit_tree():
	Global.canvas = null
