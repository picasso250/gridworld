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


var water_pos_init_center: Vector2 = Vector2(0.5, 0.5)
var water_pos: Vector2 = water_pos_init_center
var water2_pos: Vector2 = water_pos_init_center  # Second water position

@export var speed: float = 0.5
@export var animation_direction: Direction = Direction.RIGHT
@export var animation_movement: Movement = Movement.OUTWARD

@export var animation2_direction: Direction = Direction.LEFT  # Second water direction
@export var animation2_movement: Movement = Movement.OUTWARD  # Second water movement

func _ready():
	# Set initial shader parameters
	material.set_shader_parameter("pipe_size", pipe_width)
	material.set_shader_parameter("pipe_color", pipe_color)
	material.set_shader_parameter("water_color", water_color)

	# Set initial water positions based on their directions and movements
	if animation_movement == Movement.OUTWARD:
		water_pos = water_pos_init_center
	else:
		water_pos = get_edge_position(animation_direction)

	if animation2_movement == Movement.OUTWARD:
		water2_pos = water_pos_init_center
	else:
		water2_pos = get_edge_position(animation2_direction)

func _process(delta):
	# Calculate direction vectors for both waters
	var direction_vector = get_direction_vector(animation_direction, animation_movement)
	var direction2_vector = get_direction_vector(animation2_direction, animation2_movement)

	# Adjust water positions based on speed (directly moving within 0-1 range)
	water_pos += direction_vector * speed * delta
	water2_pos += direction2_vector * speed * delta

	# Check if water 1 has reached the boundary (0 to 1 range)
	if animation_movement == Movement.OUTWARD:
		if water_pos.x > 1 or water_pos.y > 1 or water_pos.x < 0 or water_pos.y < 0:
			water_pos = water_pos_init_center  # Reset to center if out of bounds
	else:
		const WATER_POSITION_THRESHOLD = 0.005
		if abs(water_pos.x - 0.5) < WATER_POSITION_THRESHOLD and abs(water_pos.y - 0.5) < WATER_POSITION_THRESHOLD:
			water_pos = get_edge_position(animation_direction)

	# Check if water 2 has reached the boundary
	if animation2_movement == Movement.OUTWARD:
		if water2_pos.x > 1 or water2_pos.y > 1 or water2_pos.x < 0 or water2_pos.y < 0:
			water2_pos = water_pos_init_center  # Reset to center if out of bounds
	else:
		if abs(water2_pos.x - 0.5) < WATER_POSITION_THRESHOLD and abs(water2_pos.y - 0.5) < WATER_POSITION_THRESHOLD:
			water2_pos = get_edge_position(animation2_direction)

	# Update both water positions in the shader
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
		Direction.UP: return Vector2(0.5, -1)
		Direction.LEFT: return Vector2(-1, 0.5)
		Direction.DOWN: return Vector2(0.5, 1)
		_: return Vector2(0, 0)
