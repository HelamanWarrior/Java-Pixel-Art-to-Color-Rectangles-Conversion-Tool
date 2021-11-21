extends Sprite

var canvas_rel_pos = Vector2()

func _ready():
	scale = Global.pixel_scale
	modulate = Global.current_pixel_color
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_process_internal(false)
