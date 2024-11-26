extends ColorRect

enum Direction { RIGHT, UP, LEFT, DOWN }
enum Movement { OUTWARD, INWARD }

@export var x: int = 0
@export var y: int = 0
@export var cell_size: float = 64
@export var pipe_width: float = 0.4
@export var draw_left_pipe: bool = true
@export var draw_right_pipe: bool = true
@export var draw_top_pipe: bool = true
@export var draw_bottom_pipe: bool = true
@export var debug: bool = false

@export var pipe_color: Color = Color(0.2, 0.1, 0.04, 1)
@export var water_color: Color = Color(0.2, 0.6, 1.0, 1)

const WATER_POSITION_THRESHOLD = 0.005

var water_pos_init_center: Vector2 = Vector2(0.5, 0.5)
@export var water_pos: Vector2 = water_pos_init_center
@export var water2_pos: Vector2 = water_pos_init_center  # Second water position

@export var animation_duration: float = 1
@export var animation_direction: Direction = Direction.RIGHT
@export var animation_movement: Movement = Movement.OUTWARD

@export var animation2_direction: Direction = Direction.LEFT  # Second water direction
@export var animation2_movement: Movement = Movement.OUTWARD  # Second water movement

var tween: Tween
var tween2: Tween

func _ready():
	# 动态创建 Tween 节点
	tween = get_tree().create_tween()
	tween2 = get_tree().create_tween()

	# 初始化 Shader 参数
	material.set_shader_parameter("pipe_size", pipe_width)
	material.set_shader_parameter("pipe_color", pipe_color)
	material.set_shader_parameter("water_color", water_color)

	# 设置初始水的位置
	water_pos = water_pos_init_center if animation_movement == Movement.OUTWARD else get_edge_position(animation_direction)
	water2_pos = water_pos_init_center if animation2_movement == Movement.OUTWARD else get_edge_position(animation2_direction)

	# 启动动画
	start_water_tween(tween, "water_pos", water_pos, animation_direction, animation_movement)
	start_water_tween(tween2, "water2_pos", water2_pos, animation2_direction, animation2_movement)


func start_water_tween(
	tween: Tween, 
	water_property: String, 
	position: Vector2, 
	direction: Direction, 
	movement: Movement
):
	# Set the destination position based on the direction
	var end_position = get_edge_position(direction)
	if movement == Movement.INWARD:
		end_position = water_pos_init_center

	# Animate the movement of water
	tween.tween_property(self, water_property, end_position, animation_duration)

func _process(delta):
	# Update shader parameters for water
	material.set_shader_parameter("water_center", water_pos)
	material.set_shader_parameter("water2_center", water2_pos)

func get_direction_vector(direction: Direction, movement: Movement):
	var base_vector = get_base_vector(direction)
	return base_vector * (1 if movement == Movement.OUTWARD else -1)

func get_base_vector(direction: Direction):
	match direction:
		Direction.RIGHT:
			return Vector2(1, 0)
		Direction.UP:
			return Vector2(0, -1)
		Direction.LEFT:
			return Vector2(-1, 0)
		Direction.DOWN:
			return Vector2(0, 1)
		_:
			return Vector2(0, 0)

func get_edge_position(direction: Direction):
	match direction:
		Direction.RIGHT: return Vector2(1, 0.5)
		Direction.UP: return Vector2(0.5, 0)
		Direction.LEFT: return Vector2(0, 0.5)
		Direction.DOWN: return Vector2(0.5, 1)
		_: return Vector2(0, 0)
