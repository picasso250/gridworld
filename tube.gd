extends ColorRect

enum Direction { RIGHT, UP, LEFT, DOWN }
enum Movement { OUTWARD, INWARD }

@export var x: int = 0
@export var y: int = 0
@export var cell_size: float = 64
@export var pipe_width: float = 0.4
@export var debug: bool = false

@export var pipe_color: Color = Color(0.6, 0.5, 0.45, 1.0)
@export var water_color: Color = Color(0.2, 0.6, 1.0, 1)

@export var show_left_arm: bool = false
func set_show_left_arm(value: bool):
	show_left_arm = value
	material.set_shader_parameter("show_left_arm", value)

@export var show_right_arm: bool = false
func set_show_right_arm(value: bool):
	show_right_arm = value
	material.set_shader_parameter("show_right_arm", value)

@export var show_top_arm: bool = false
func set_show_top_arm(value: bool):
	show_top_arm = value
	material.set_shader_parameter("show_top_arm", value)

@export var show_bottom_arm: bool = false
func set_show_bottom_arm(value: bool):
	show_bottom_arm = value
	material.set_shader_parameter("show_bottom_arm", value)

@export var show_center_circle: bool = true
func set_show_center_circle(value: bool):
	show_center_circle = value
	material.set_shader_parameter("show_center_circle", value)

func _ready():
	# Initialize Shader parameters
	material.set_shader_parameter("pipe_color", pipe_color)
	material.set_shader_parameter("water_color", water_color)
	material.set_shader_parameter("show_left_arm", show_left_arm)
	material.set_shader_parameter("show_right_arm", show_right_arm)
	material.set_shader_parameter("show_top_arm", show_top_arm)
	material.set_shader_parameter("show_bottom_arm", show_bottom_arm)
	material.set_shader_parameter("show_center_circle", show_center_circle)
	tooltip_text = ""+str(x)+","+str(y)

func _process(delta):
	pass

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			show_center_circle = !show_center_circle
			material.set_shader_parameter("show_center_circle", show_center_circle)
