extends Control

enum Direction { RIGHT, UP, LEFT, DOWN }
enum Movement { OUTWARD, INWARD }

@export var x: int = 0
@export var y: int = 0
@export var cell_size: float = 64
@export var pipe_width: float = 32
@export var pipe_thickness: float = 4
@export var draw_left_pipe: bool = true
@export var draw_right_pipe: bool = true
@export var draw_top_pipe: bool = true
@export var draw_bottom_pipe: bool = true
@export var debug: bool = false

@export var pipe_color: Color = Color(0.2, 0.1, 0.04, 1)
@export var water_color: Color = Color(0.2, 0.6, 1.0, 1)

var water_size = pipe_width - pipe_thickness * 2

var water_pos: Vector2 = Vector2(0, 0)
@export var speed: float = 33
@export var animation_direction: Direction = Direction.RIGHT
@export var animation_movement: Movement = Movement.OUTWARD # Added parameter for inward/outward


func _ready():
	pass

func _draw():
	if draw_left_pipe:
		# 绘制左半边的管道
		draw_rect(Rect2(Vector2(-cell_size / 2, -pipe_width / 2), Vector2(cell_size / 2 + pipe_width / 2, pipe_width)), pipe_color)

	if draw_right_pipe:
		# 绘制右半边的管道
		draw_rect(Rect2(Vector2(-pipe_width / 2, -pipe_width / 2), Vector2(cell_size / 2 + pipe_width / 2, pipe_width)), pipe_color)

	if draw_top_pipe:
		# 绘制上半边的管道
		draw_rect(Rect2(Vector2(-pipe_width / 2, -cell_size / 2), Vector2(pipe_width, cell_size / 2 + pipe_width / 2)), pipe_color)

	if draw_bottom_pipe:
		# 绘制下半边的管道
		draw_rect(Rect2(Vector2(-pipe_width / 2, -pipe_width / 2), Vector2(pipe_width, cell_size / 2 + pipe_width / 2)), pipe_color)

	# 绘制水：考虑管道壁的厚度
	draw_rect(Rect2(water_pos-Vector2(water_size/2,water_size/2), Vector2(water_size, water_size)), water_color)

	if debug:
		# 绘制调试十字
		var cross_color: Color = Color(0.8, 0.8, 0.8, 0.1) # 淡灰色
		draw_rect(Rect2(Vector2(-cell_size / 2, -pipe_width / 2), Vector2(cell_size, pipe_width)), cross_color)
		draw_rect(Rect2(Vector2(-pipe_width / 2, -cell_size / 2), Vector2(pipe_width, cell_size)), cross_color)

func _process(delta):
	var direction_vector = get_direction_vector(animation_direction, animation_movement)
	water_pos += direction_vector * speed * delta

	# Check boundaries and reset if needed.  Logic depends on movement type.
	if animation_movement == Movement.OUTWARD:
		if abs(water_pos.x) > cell_size / 2 or abs(water_pos.y) > cell_size / 2:
			water_pos = Vector2(0, 0)
	else: #INWARD
		if water_pos.distance_to(Vector2.ZERO) < 1: #Check if close enough to center
			water_pos = get_edge_position(animation_direction)


	queue_redraw()


func get_direction_vector(direction: Direction, movement: Movement):
	var base_vector = get_base_vector(direction)
	return base_vector * ( 1 if movement == Movement.OUTWARD else -1)


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
		Direction.RIGHT: return Vector2(cell_size/2,0)
		Direction.UP: return Vector2(0,-cell_size/2)
		Direction.LEFT: return Vector2(-cell_size/2,0)
		Direction.DOWN: return Vector2(0,cell_size/2)
		_: return Vector2(0,0)
